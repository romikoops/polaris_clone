class AddRouteLoadInfoToRoute < ActiveRecord::Migration[5.1]
  def change
    add_column :routes, :has_fcl, :boolean
    add_column :routes, :has_lcl, :boolean
  end
end
