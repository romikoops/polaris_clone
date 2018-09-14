class AddQuoteToShipment < ActiveRecord::Migration[5.2]
  def change
    add_column :shipments, :quote_id, :integer
  end
end
