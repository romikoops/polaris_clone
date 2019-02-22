# frozen_string_literal: true

class CreateTruckingPricingScopes < ActiveRecord::Migration[5.1]
  def change
    create_table :trucking_pricing_scopes do |t|
      t.string :load_type
      t.string :cargo_class
      t.string :carriage
      t.integer :courier_id
      t.string :truck_type

      t.timestamps
    end
  end
end
