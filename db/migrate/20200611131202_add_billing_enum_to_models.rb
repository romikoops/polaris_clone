class AddBillingEnumToModels < ActiveRecord::Migration[5.2]
  def up
    add_column :shipments, :billing, :integer, index: true
    add_column :quotations, :billing, :integer, index: true
    change_column_default :shipments, :billing, 0
    change_column_default :quotations, :billing, 0
  end

  def down
    remove_column :shipments, :billing
    remove_column :quotations, :billing
  end
end
