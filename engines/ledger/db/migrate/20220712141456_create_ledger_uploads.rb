# frozen_string_literal: true

class CreateLedgerUploads < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL.squish
        CREATE TYPE ledger_uploads_status AS ENUM (
          'not_started',
          'superseded',
          'processing',
          'failed',
          'done'
        );
      SQL
    end

    create_table :ledger_uploads, id: :uuid do |t|
      t.references :organization, type: :uuid, index: true, null: false, foreign_key: { to_table: "organizations_organizations" }
      t.references :file, type: :uuid, index: true, null: false, foreign_key: { to_table: "legacy_files" }
      t.references :user, type: :uuid, index: true, foreign_key: { to_table: "users_users" }
      t.column :status, :excel_data_services_uploads_status, index: true, null: false
      t.uuid :last_job_id, index: true
      t.jsonb :excel_data_services_uploads, :processing_errors
      t.timestamps
    end
  end

  def down
    drop_table :ledger_uploads

    safety_assured do
      execute <<-SQL.squish
        DROP TYPE ledger_uploads_status;
      SQL
    end
  end
end
