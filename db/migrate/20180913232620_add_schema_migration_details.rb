# frozen_string_literal: true

# Takes from https://github.com/discourse/discourse/blob/fd931b948dc271168524e5c5059146dbdd8b20c3/db/migrate/20000225050318_add_schema_migration_details.rb
class AddSchemaMigrationDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :schema_migration_details do |t|
      t.string :version, null: false
      t.string :name
      t.string :hostname
      t.string :git_version
      t.string :rails_version
      t.integer :duration
      t.string :direction # this really should be a pg enum type but annoying to wire up for little gain
      t.datetime :created_at, null: false
    end

    add_index :schema_migration_details, [:version]

    reversible do |dir|
      dir.up do
        execute("INSERT INTO schema_migration_details(version, created_at)
                 SELECT version, current_timestamp
                 FROM schema_migrations
                 ORDER BY version
                ")
      end
    end
  end
end
