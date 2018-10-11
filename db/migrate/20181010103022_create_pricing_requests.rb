class CreatePricingRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :pricing_requests do |t|
      t.integer :pricing_id, index: true
      t.integer :user_id, index: true
      t.integer :tenant_id, index: true
      t.string :status
      t.timestamps
    end
  end
end
