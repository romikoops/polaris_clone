class AddMotScopeToRoutes < ActiveRecord::Migration[5.1]
  def change
    add_reference :routes, :mot_scope, foreign_key: true
  end
end
