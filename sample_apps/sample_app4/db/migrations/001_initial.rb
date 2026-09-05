# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :posts do
      primary_key :id
      String :title, null: false, size: 100
      String :description, text: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end

    create_table :comments do
      primary_key :id
      foreign_key :post_id, :posts, on_delete: :cascade, null: false
      String :content, text: true, null: false
      String :author, size: 100
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      index :post_id
    end
  end
end
