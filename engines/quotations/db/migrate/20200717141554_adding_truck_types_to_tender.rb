class AddingTruckTypesToTender < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_tenders, :pickup_truck_type, :string
    add_column :quotations_tenders, :delivery_truck_type, :string
  end
end
