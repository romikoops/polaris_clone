# frozen_string_literal: true
class CreateRoutingTerminals < ActiveRecord::Migration[5.2]
  def change
    create_table :routing_terminals, id: :uuid do |t|
      t.uuid :location_id
      t.geometry :center, index: true
      t.string :terminal_code
      t.boolean :default, default: false
      t.timestamps
    end
  end
end
