# frozen_string_literal: true

class CreateTruckingPostalCodes < ActiveRecord::Migration[5.2]
  set_lock_timeout(1000)
  set_statement_timeout(3000)

  def change
    create_table :trucking_postal_codes, id: :uuid do |t|
      t.citext :postal_code, null: false, index: true
      t.references :country, index: true, null: false
      t.geometry :point, limit: { srid: 4326, type: "point" }, null: false
      t.index %i[postal_code country_id], unique: true
      t.timestamps
    end
  end
end
