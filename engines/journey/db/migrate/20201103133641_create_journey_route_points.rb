class CreateJourneyRoutePoints < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_route_points, id: :uuid do |t|
      t.string :function, null: false
      t.string :name, null: false
      t.geometry :coordinates, null: false, limti: {srid: 4326}
      t.timestamps
    end

    safety_assured do
      add_presence_constraint :journey_route_points, :name
      add_presence_constraint :journey_route_points, :function
    end
  end
end
