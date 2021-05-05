# frozen_string_literal: true

class AddUpsertIdToLocations < ActiveRecord::Migration[5.2]
  def up
    add_column :trucking_locations, :upsert_id, :uuid
  end
end
