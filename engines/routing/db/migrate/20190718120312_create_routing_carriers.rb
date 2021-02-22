# frozen_string_literal: true
class CreateRoutingCarriers < ActiveRecord::Migration[5.2]
  def change
    create_table :routing_carriers, id: :uuid do |t|
      t.string :name
      t.string :abbreviated_name
      t.string :code, unique: true
      t.timestamps
    end
  end
end
