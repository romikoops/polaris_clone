# frozen_string_literal: true

class CreateRmsDataSheets < ActiveRecord::Migration[5.2]
  def change
    create_table :rms_data_sheets, id: :uuid do |t|
      t.integer :sheet_index, index: true
      t.uuid :tenant_id, index: true
      t.uuid :book_id, index: true
      t.string :name
      t.jsonb :metadata, default: {}
      t.timestamps
    end
  end
end
