# frozen_string_literal: true

class MigrateActiveStorageRecordIds < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      rename_column :active_storage_attachments, :record_id, 'record_id_20200211'
      rename_column :active_storage_attachments, :record_type, 'record_type_20200211'
      rename_column :active_storage_attachments, :new_record_id, :record_id
      rename_column :active_storage_attachments, :new_record_type, :record_type
    end
  end
end
