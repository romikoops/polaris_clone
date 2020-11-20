# frozen_string_literal: true

class CreateTruckingCoverages < ActiveRecord::Migration[5.2]
  def change
    create_table :trucking_coverages, id: :uuid do |t|
      t.integer :hub_id
      t.geometry "bounds", limit: {srid: 0, type: "geometry"}
      t.timestamps
    end
  end
end
