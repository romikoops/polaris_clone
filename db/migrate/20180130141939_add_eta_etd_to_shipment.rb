class AddEtaEtdToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :planned_eta, :datetime
    add_column :shipments, :planned_etd, :datetime
  end
end
