# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table :cards do
      add_column :position, Integer, default: 0
      add_column :priority, String, null: false, default: 'normal'
      add_column :assignee, String, size: 100
      add_column :due_date, Date
      add_column :archived, TrueClass, null: false, default: false
      add_index [:archived, :status, :position]
      add_index :assignee
      add_index :due_date
      # SQLite rebuilds the table for a constraint change; use one combined
      # constraint so successive rebuilds cannot discard earlier CHECK clauses.
      add_constraint(:valid_card, Sequel.&(
        {status: ['Todo', 'In Progress', 'Done']},
        {priority: %w[low normal high urgent]},
        Sequel.lit('((archived = FALSE AND position IS NOT NULL AND position >= 0) OR (archived = TRUE AND position IS NULL))')
      ))
    end

    ['Todo', 'In Progress', 'Done'].each do |status|
      self[:cards].where(status: status).order(:id).all.each_with_index do |card, index|
        self[:cards].where(id: card[:id]).update(position: index)
      end
    end
  end

  down do
    alter_table :cards do
      drop_constraint :valid_card
      drop_index [:archived, :status, :position]
      drop_index :assignee
      drop_index :due_date
      drop_column :position
      drop_column :priority
      drop_column :assignee
      drop_column :due_date
      drop_column :archived
    end
  end
end
