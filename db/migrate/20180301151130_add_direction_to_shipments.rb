class AddDirectionToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :direction, :string
  end
end
