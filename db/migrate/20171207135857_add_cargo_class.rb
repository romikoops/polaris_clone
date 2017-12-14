class AddCargoClass < ActiveRecord::Migration[5.1]
  def change
    add_column :transport_types, :cargo_class, :string
    add_column :vehicle_types, :mot, :string
  end
end
