class AddQuotationIdToShipment < ActiveRecord::Migration[5.2]
  def change
    add_column :shipments, :quotation_id, :integer
  end
end
