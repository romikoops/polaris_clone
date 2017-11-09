class AddDedicatedBoolToPricing < ActiveRecord::Migration[5.1]
  def change
    add_column :pricings, :dedicated, :boolean
  end
end
