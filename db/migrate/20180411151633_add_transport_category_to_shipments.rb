class AddTransportCategoryToShipments < ActiveRecord::Migration[5.1]
  def change
    add_reference :shipments, :transport_category, foreign_key: true
  end
end
