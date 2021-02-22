# frozen_string_literal: true
class CreateRoutingLineServices < ActiveRecord::Migration[5.2]
  def change
    create_table :routing_line_services, id: :uuid do |t|
      t.string :name
      t.uuid :carrier_id, index: true
      t.integer :category, default: 0, null: false
      t.timestamps
    end
  end
end
