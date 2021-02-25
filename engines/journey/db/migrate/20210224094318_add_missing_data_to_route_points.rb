# frozen_string_literal: true

class AddMissingDataToRoutePoints < ActiveRecord::Migration[5.2]
  def up
    add_column :journey_route_points, :postal_code, :string
    change_column_default :journey_route_points, :postal_code, ""
    add_column :journey_route_points, :city, :string
    change_column_default :journey_route_points, :city, ""
    add_column :journey_route_points, :country, :string
    add_column :journey_route_points, :street, :string
    change_column_default :journey_route_points, :street, ""
    add_column :journey_route_points, :street_number, :string
    change_column_default :journey_route_points, :street_number, ""
    add_column :journey_route_points, :administrative_area, :string
    change_column_default :journey_route_points, :administrative_area, ""
  end

  def down
    remove_column :journey_route_points, :postal_code
    remove_column :journey_route_points, :city
    remove_column :journey_route_points, :country
    remove_column :journey_route_points, :street
    remove_column :journey_route_points, :street_number
    remove_column :journey_route_points, :administrative_area
  end
end
