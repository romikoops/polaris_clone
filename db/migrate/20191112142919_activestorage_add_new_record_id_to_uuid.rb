# frozen_string_literal: true

class ActivestorageAddNewRecordIdToUuid < ActiveRecord::Migration[5.2]
  def change
    add_column :active_storage_attachments, :new_record_id, :uuid
    add_column :active_storage_attachments, :new_record_type, :string
  end
end
