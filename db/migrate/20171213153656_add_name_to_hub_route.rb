class AddNameToHubRoute < ActiveRecord::Migration[5.1]
  def change
    add_column :hub_routes, :name, :string
  end
end
