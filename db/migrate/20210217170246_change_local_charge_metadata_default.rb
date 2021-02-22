class ChangeLocalChargeMetadataDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :local_charges, :metadata, {}
  end
end
