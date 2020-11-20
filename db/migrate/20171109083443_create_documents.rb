# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
      t.integer :user_id
      t.integer :shipment_id
      t.string :doc_type
      t.string :url
      t.string :text
      t.timestamps
    end
  end
end
