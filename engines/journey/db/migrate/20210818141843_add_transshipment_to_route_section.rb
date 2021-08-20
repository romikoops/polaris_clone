# frozen_string_literal: true

class AddTransshipmentToRouteSection < ActiveRecord::Migration[5.2]
  def change
    add_column :journey_route_sections, :transshipment, :string
  end
end
