class CreatePricingRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :pricing_requests do |t|
      t.integer :pricing_id
      t.integer :user_id
      t.integer :tenant_id
      t.string :status
      t.timestamps
    end
  end
end
