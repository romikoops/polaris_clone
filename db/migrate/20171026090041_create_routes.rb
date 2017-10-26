class CreateRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :routes do |t|
			t.integer :starthub_id
      t.integer :endhub_id
      
      t.string :name
      t.string :trade_direction
      t.timestamps
    end
  end
end
