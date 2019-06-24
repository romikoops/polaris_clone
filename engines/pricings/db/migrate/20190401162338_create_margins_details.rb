# frozen_string_literal: true

class CreateMarginsDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :pricings_details, id: :uuid do |t|
      t.uuid :tenant_id, index: true
      t.uuid :margin_id, index: true
      t.decimal :value
      t.string :operator
      t.integer :charge_category_id
      t.timestamps
    end
  end
end
