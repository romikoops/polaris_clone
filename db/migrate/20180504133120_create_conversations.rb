class CreateConversations < ActiveRecord::Migration[5.1]
  def change
    create_table :conversations do |t|
      t.integer :shipment_id
      t.integer :tenant_id
      t.integer :user_id
      t.integer :manager_id
      t.timestamps
    end
  end
end
