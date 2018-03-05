class EditingIncotermsValues < ActiveRecord::Migration[5.1]
  def change
    remove_column :shipments, :incoterm, :string
    add_column :shipments, :incoterm, :jsonb
  end
end
