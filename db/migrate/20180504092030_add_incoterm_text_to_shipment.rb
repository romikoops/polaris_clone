class AddIncotermTextToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :incoterm_text, :string
  end
end
