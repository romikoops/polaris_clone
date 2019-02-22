# frozen_string_literal: true

class RemoveCourierIdFromTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    remove_column :trucking_pricings, :courier_id, :integer
  end
end
