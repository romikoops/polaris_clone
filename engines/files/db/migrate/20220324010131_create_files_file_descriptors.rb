# frozen_string_literal: true

class CreateFilesFileDescriptors < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL.squish
        CREATE TYPE file_sync_status AS ENUM ('ready', 'in_progress', 'synced', 'failed');
      SQL
    end
    create_table :files_file_descriptors, id: :uuid do |t|
      t.string :file_path, null: false, index: true
      t.string :file_type, null: false
      t.string :originator, null: false
      t.string :source, null: false
      t.string :source_type, null: false
      t.string :synced_at
      t.string :file_created_at
      t.string :file_updated_at
      t.string :file_added_to_source_at
      t.column :status, :file_sync_status, null: false
      t.references :organization, type: :uuid, index: true,
        foreign_key: { to_table: "organizations_organizations" }
      t.timestamps
    end

    safety_assured do
      add_index :files_file_descriptors, %i[organization_id file_path], unique: true
      add_presence_constraint :files_file_descriptors, :file_path
      add_presence_constraint :files_file_descriptors, :file_type
      add_presence_constraint :files_file_descriptors, :originator
      add_presence_constraint :files_file_descriptors, :source
    end
  end

  def down
    drop_table :files_file_descriptors
    execute <<-SQL.squish
      DROP TYPE file_sync_status
    SQL
  end
end
