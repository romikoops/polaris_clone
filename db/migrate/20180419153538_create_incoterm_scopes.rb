class CreateIncotermScopes < ActiveRecord::Migration[5.1]
  def change
    create_table :incoterm_scopes do |t|
      t.boolean :pre_carriage
      t.boolean :on_carriage
      t.timestamps
    end
  end
end
