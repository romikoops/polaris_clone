class MoveLoadTypeToTruckingPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :trucking_pricings, :load_type, :string
  end
end
