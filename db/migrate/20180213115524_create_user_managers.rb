class CreateUserManagers < ActiveRecord::Migration[5.1]
  def change
    create_table :user_managers do |t|
        t.integer :manager_id
        t.integer :user_id
        t.string :section
      t.timestamps
    end
  end
end
