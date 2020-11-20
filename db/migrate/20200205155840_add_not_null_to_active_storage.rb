# frozen_string_literal: true

class AddNotNullToActiveStorage < ActiveRecord::Migration[5.2]
  def change
    change_column_null :active_storage_attachments, :record_id, false
    change_column_null :active_storage_attachments, :record_type, false
    change_column_null :active_storage_attachments, "record_id_20200211", true
    change_column_null :active_storage_attachments, "record_type_20200211", true
  end
end
