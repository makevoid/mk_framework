# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :todos do
      primary_key :id
      String :title, null: false, size: 100
      String :description, text: true
      TrueClass :completed, default: false, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
