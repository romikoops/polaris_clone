# frozen_string_literal: true
class CreateJourneyQueries < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_queries, id: :uuid do |t|
      t.references :organization, type: :uuid, index: true,
                                  foreign_key: {to_table: "organizations_organizations", on_delete: :cascade},
                                  dependent: :destroy
      t.references :creator, type: :uuid, index: true,
                             foreign_key: {to_table: "users_users", on_delete: :cascade}
      t.references :client, type: :uuid, index: true,
                            foreign_key: {to_table: "users_users", on_delete: :cascade}
      t.references :company, type: :uuid, index: true,
                             foreign_key: {to_table: "companies_companies", on_delete: :cascade}
      t.uuid :source_id, null: false
      t.string :origin, null: false
      t.string :destination, null: false
      t.geometry :origin_coordinates, null: false, limit: {srid: 4326}
      t.geometry :destination_coordinates, null: false, limit: {srid: 4326}
      t.boolean :customs, default: false
      t.boolean :insurance, default: false
      t.datetime :cargo_ready_date, null: false
      t.datetime :delivery_date, null: false
      t.timestamps
    end

    safety_assured do
      add_presence_constraint :journey_queries, :origin
      add_presence_constraint :journey_queries, :origin_coordinates
      add_presence_constraint :journey_queries, :destination
      add_presence_constraint :journey_queries, :destination_coordinates

      add_check_constraint :journey_queries, "delivery_date > cargo_ready_date", name: "delivery_after_cargo_ready_date"
    end
  end
end
