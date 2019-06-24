# frozen_string_literal: true

class CreateLegacyVehicles < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_vehicles, id: :uuid, &:timestamps
  end
end
