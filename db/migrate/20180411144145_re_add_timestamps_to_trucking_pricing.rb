# frozen_string_literal: true

class ReAddTimestampsToTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_pricings, :created_at, :datetime
    add_column :trucking_pricings, :updated_at, :datetime
  end
end
