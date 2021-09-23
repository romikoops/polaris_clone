# frozen_string_literal: true

class CreateSchedulesSchedule < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules_schedules, id: :uuid do |t|
      t.references :organization, type: :uuid, index: true,
                                  foreign_key: { to_table: "organizations_organizations", on_delete: :cascade },
                                  dependent: :destroy

      t.string :voyage_code, default: ""
      t.string :vessel_name, default: ""
      t.string :vessel_code, default: ""
      t.string :carrier, default: ""
      t.string :service, default: ""
      t.string :origin, null: false
      t.string :destination, null: false
      t.datetime :origin_departure, null: false
      t.datetime :destination_arrival, null: false
      t.datetime :closing_date, null: false
      t.timestamps
    end

    safety_assured do
      add_presence_constraint :schedules_schedules, :origin
      add_presence_constraint :schedules_schedules, :destination

      add_check_constraint :schedules_schedules, "destination_arrival > origin_departure", name: "arrival_after_departure"
      add_check_constraint :schedules_schedules, "origin_departure >= closing_date", name: "departure_after_or_equal_to_closing_date"
    end
  end
end
