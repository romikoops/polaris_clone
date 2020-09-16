class AddParanoiaToLegacyChargeModels < ActiveRecord::Migration[5.2]
  def change
    add_column :charge_breakdowns, :deleted_at, :datetime
    add_column :charges, :deleted_at, :datetime
  end
end
