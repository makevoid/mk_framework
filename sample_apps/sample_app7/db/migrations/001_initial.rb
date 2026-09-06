# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :cards do
      primary_key :id
      String :title, null: false, size: 100
      String :description, text: true
      String :status, default: 'Todo', null: false
      Integer :position, default: 0
      String :priority, null: false, default: 'normal'
      String :assignee, size: 100
      Date :due_date
      TrueClass :archived, null: false, default: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      index [:archived, :status, :position]
      index :assignee
      index :due_date
      constraint(:valid_card, Sequel.&(
        {status: ['Todo', 'In Progress', 'Done']},
        {priority: %w[low normal high urgent]},
        Sequel.lit('((archived = FALSE AND position IS NOT NULL AND position >= 0) OR (archived = TRUE AND position IS NULL))')
      ))
    end

    create_table :comments do
      primary_key :id
      foreign_key :card_id, :cards, on_delete: :cascade, null: false
      String :content, text: true, null: false
      String :author, size: 100
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      index :card_id
    end
  end
end
