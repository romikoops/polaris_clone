# frozen_string_literal: true

class RemoveLoadTypeFromTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    remove_column :trucking_pricings, :load_type, :string
  end
end
