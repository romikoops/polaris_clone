class AddEoriToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :eori, :string
  end
end
