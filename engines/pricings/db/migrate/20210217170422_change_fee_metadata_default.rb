class ChangeFeeMetadataDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :pricings_fees, :metadata, {}
  end
end
