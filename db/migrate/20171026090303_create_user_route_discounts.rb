class CreateUserRouteDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :user_route_discounts do |t|
    	t.integer :user_id
      t.integer :route_id

      t.decimal :discount_by
      t.timestamps
    end
  end
end
