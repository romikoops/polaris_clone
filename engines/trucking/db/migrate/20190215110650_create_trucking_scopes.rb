# frozen_string_literal: true

class CreateTruckingScopes < ActiveRecord::Migration[5.2]
  def change
    create_table :trucking_scopes, id: :uuid do |t|
      t.string 'load_type'
      t.string 'cargo_class'
      t.string 'carriage'
      t.uuid 'courier_id'
      t.string 'truck_type'
      t.timestamps
    end
  end
end
