# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :cards do
      primary_key :id
      String :title, null: false, size: 100
      String :description, text: true
      String :status, default: 'Todo', null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
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
