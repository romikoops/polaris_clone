class CreateTrainPricings < ActiveRecord::Migration[5.1]
  def change
    create_table :train_pricings do |t|
    	t.string :starthub_name
      t.string :endhub_name

      t.string :size
      t.string :weight_class
      
      t.decimal :price
      t.timestamps
    end
  end
end
