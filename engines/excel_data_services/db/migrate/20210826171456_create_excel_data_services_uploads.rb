# frozen_string_literal: true

class CreateExcelDataServicesUploads < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE excel_data_services_uploads_status AS ENUM (
          'not_started',
          'superseded',
          'processing',
          'failed',
          'done'
        );
      SQL
    end

    create_table :excel_data_services_uploads, id: :uuid do |t|
      t.references :organization, type: :uuid, index: true, null: false, foreign_key: { to_table: "organizations_organizations" }
      t.references :file, type: :uuid, index: true, null: false, foreign_key: { to_table: "legacy_files" }
      t.references :user, type: :uuid, index: true, foreign_key: { to_table: "users_users" }
      t.column :status, :excel_data_services_uploads_status, index: true, null: false
      t.uuid :last_job_id, index: true
      t.timestamps
    end
  end

  def down
    drop_table :excel_data_services_uploads

    safety_assured do
      execute <<-SQL
        DROP TYPE excel_data_services_uploads_status;
      SQL
    end
  end
end
