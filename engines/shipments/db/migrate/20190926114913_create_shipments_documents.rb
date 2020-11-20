# frozen_string_literal: true

class CreateShipmentsDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :shipments_documents, id: :uuid do |t|
      t.references :attachable, polymorphic: true, type: :uuid, null: false
      t.references :sandbox, foreign_key: {to_table: :tenants_sandboxes}, type: :uuid, index: true
      t.integer :doc_type
      t.string :file_name
      t.timestamps
    end
  end
end
