# frozen_string_literal: true

class ReaddUniqueIndexOnActivestorageAttachemtns < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    remove_index :active_storage_attachments, name: 'index_active_storage_attachments_uniqueness'
    add_index :active_storage_attachments, %i[record_type record_id name blob_id], unique: true, algorithm: :concurrently, name: 'index_active_storage_attachments_uniqueness'
  end
end
