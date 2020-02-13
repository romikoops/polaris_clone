# frozen_string_literal: true

class CreateLegacyFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_files, id: :uuid do |t|
      t.jsonb :approval_details
      t.string :approved
      t.string :doc_type
      t.integer :quotation_id, index: true
      t.uuid :sandbox_id, index: true
      t.integer :shipment_id, index: true
      t.integer :tenant_id, index: true
      t.string :text
      t.string :url
      t.integer :user_id
      t.timestamps
    end
  end
end
