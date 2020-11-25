class CreateJourneyRouteSections < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE journey_mode_of_transport AS ENUM ('ocean', 'air', 'rail', 'truck', 'carriage');
      SQL
    end
    create_table :journey_route_sections, id: :uuid do |t|
      t.references :from, type: :uuid, index: true,
                          foreign_key: {on_delete: :cascade, to_table: "journey_route_points"}
      t.references :to, type: :uuid, index: true,
                        foreign_key: {on_delete: :cascade, to_table: "journey_route_points"}
      t.references :result, type: :uuid, index: true,
                            foreign_key: {on_delete: :cascade, to_table: "journey_results"}
      t.string :carrier, null: false
      t.string :service, null: false
      t.integer :order, null: false
      t.column :mode_of_transport, :journey_mode_of_transport, index: true
      t.timestamps
    end

    safety_assured do
      add_presence_constraint :journey_route_sections, :service
      add_presence_constraint :journey_route_sections, :carrier
    end
  end

  def down
    drop_table :journey_route_sections

    safety_assured do
      execute <<-SQL
        DROP TYPE journey_mode_of_transport;
      SQL
    end
  end
end
