# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :weathers do
      primary_key :id
      String :location, null: false, size: 100
      String :data, text: true, null: false
      DateTime :fetched_at, null: false
      index :location, unique: true
    end
  end
end
