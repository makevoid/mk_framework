# frozen_string_literal: true

require_relative '../../cards/controllers/base'

module SampleApp7
  class BoardIndexController < CardsController
    route do |r|
      page = r.page
      scope = filtered_dataset(r)
      if MK::Input.new(r.GET).permit(archived: :boolean)[:archived]
        raise MK::BadRequest, 'Use /cards?archived=true to browse the archive'
      end
      DB.transaction do
        columns = Card::STATUSES.map do |status|
          cards = scope.where(status: status)
          {status: status, total: cards.count,
           cards: cards.limit(page[:limit], page[:offset]).all}
        end
        {columns: columns, total: columns.sum { |column| column[:total] }, **page}
      end
    end
  end
end
