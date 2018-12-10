class CreateContents < ActiveRecord::Migration[5.2]
  def change
    create_table :contents do |t|
      t.jsonb :text, default: {}
      t.string :component
      t.string :section
      t.integer :index

      t.timestamps
    end
  end
end
