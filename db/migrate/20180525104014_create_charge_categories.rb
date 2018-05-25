class CreateChargeCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :charge_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
