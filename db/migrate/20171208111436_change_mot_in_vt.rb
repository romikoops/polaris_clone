class ChangeMotInVt < ActiveRecord::Migration[5.1]
  def change
    add_column :vehicle_types, :mode_of_transport, :string
    add_column :transport_types, :mode_of_transport, :string
  end
end
