class CreateRateBases < ActiveRecord::Migration[5.2]
  def change
    create_table :rate_bases do |t|
      t.string :external_code
      t.string :internal_code
      t.timestamps
    end
  end
end
