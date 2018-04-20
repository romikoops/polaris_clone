class ChangeIncotermOnShipment < ActiveRecord::Migration[5.1]
  def change
    remove_column :shipments, :incoterm, :jsonb
    add_column :shipments, :incoterm_id, :integer
  end
end
