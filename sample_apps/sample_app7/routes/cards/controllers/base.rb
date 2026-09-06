# frozen_string_literal: true

require 'date'

module SampleApp7
  class CardsController < Controller
    def dataset(_r) = Card.dataset

    def find(r)
      dataset(r).where(id: r.path_params.fetch(:id)).first or raise MK::NotFound, 'Card not found'
    end

    def attributes(r, move: false)
      fields = {status: String, position: [Integer, String]}
      unless move
        fields.merge!(title: [String, NilClass], description: [String, NilClass],
                      priority: String, assignee: [String, NilClass],
                      due_date: [String, NilClass], archived: :boolean)
      end
      values = r.input.permit(**fields)
      values[:position] = r.input.integer(:position, default: 0) if values.key?(:position)
      if move && values.empty?
        raise MK::BadRequest, 'Supply status or position to move a card'
      end
      if values[:due_date]
        begin
          raise ArgumentError unless values[:due_date].match?(/\A\d{4}-\d{2}-\d{2}\z/)

          date = Date.iso8601(values[:due_date])
          raise ArgumentError unless date.iso8601 == values[:due_date]

          values[:due_date] = date
        rescue ArgumentError
          raise MK::ValidationError.new(details: {due_date: ['must be a valid YYYY-MM-DD date']})
        end
      end
      values
    end

    def filtered_dataset(r)
      input = MK::Input.new(r.GET)
      filters = input.permit(status: String, priority: String, assignee: String,
                             q: String, archived: :boolean, overdue: :boolean)
      {status: Card::STATUSES, priority: Card::PRIORITIES}.each do |field, choices|
        if filters.key?(field) && !choices.include?(filters[field])
          raise MK::BadRequest, "Invalid parameter: #{field}"
        end
      end
      scope = dataset(r).where(archived: filters.fetch(:archived, false))
      %i[status priority assignee].each do |field|
        scope = scope.where(field => filters[field]) if filters.key?(field)
      end
      if filters[:q]
        raise MK::BadRequest, 'Search is limited to 200 characters' if filters[:q].length > 200

        # Escape LIKE wildcards so the search term is treated as literal text.
        term = "%#{filters[:q].gsub(/[\\%_]/) { |character| "\\#{character}" }}%"
        scope = scope.where(Sequel.|(Sequel.ilike(:title, term), Sequel.ilike(:description, term)))
      end
      if filters.key?(:overdue)
        overdue = Sequel.&(Sequel[:due_date] < Date.today, Sequel.~(status: 'Done'))
        scope = if filters[:overdue]
                  scope.where(overdue)
                else
                  scope.where(Sequel.|({due_date: nil}, Sequel.~(overdue)))
                end
      end
      scope.order(Sequel.case(Card::STATUSES.each_with_index.to_h, 3, :status), :position, :id)
    end

    def lane(status)
      Card.where(status: status, archived: false)
    end

    # SQLite's immediate transaction serializes writers before reading positions.
    # Return hashes after explicit writes so framework dispatch never saves twice.
    def write_card(r, create: false, move: false)
      values = attributes(r, move: move)
      DB.transaction(mode: :immediate) do
        record = create ? Card.new : find(r)
        raise MK::Conflict, 'Restore an archived card before moving it' if move && record.archived

        previous = record.values.dup unless create
        record.set(values.reject { |key, _| key == :position })
        reposition = create || values.key?(:position) ||
                     previous[:status] != record.status || previous[:archived] != record.archived
        if reposition
          if record.archived
            raise MK::BadRequest, 'Archived cards cannot have a position' if values.key?(:position)

            record.position = nil
          else
            destination = lane(record.status)
            destination = destination.exclude(id: record.id) unless create
            size = destination.count
            same_lane = previous && !previous[:archived] && previous[:status] == record.status
            position = values.fetch(:position) { same_lane ? previous[:position] : size }
            if position > size
              raise MK::ValidationError.new(details: {position: ["must be between 0 and #{size}"]})
            end
            record.position = position
          end

          if previous && !previous[:archived]
            lane(previous[:status]).exclude(id: record.id).
              where(Sequel[:position] > previous[:position]).
              update(position: Sequel[:position] - 1, updated_at: Time.now)
          end
          unless record.archived
            scope = lane(record.status)
            scope = scope.exclude(id: record.id) unless create
            scope.where(Sequel[:position] >= record.position).
              update(position: Sequel[:position] + 1, updated_at: Time.now)
          end
        end
        persist(record).values
      end
    end

    def delete_card(r)
      DB.transaction(mode: :immediate) do
        record = find(r)
        destroy(record)
        unless record.archived
          lane(record.status).where(Sequel[:position] > record.position).
            update(position: Sequel[:position] - 1, updated_at: Time.now)
        end
        record.values
      end
    end
  end
end
