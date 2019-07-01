class BackfillPricingsInternalFlag < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  
  def change
    Pricing.in_batches.update_all internal: false
  end
end
