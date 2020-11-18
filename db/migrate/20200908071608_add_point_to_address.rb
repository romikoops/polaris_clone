class AddPointToAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :point, :geometry, limit: {srid: 4326, type: "point"}
  end
end
