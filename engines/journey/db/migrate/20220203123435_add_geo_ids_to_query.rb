# frozen_string_literal: true

class AddGeoIdsToQuery < ActiveRecord::Migration[5.2]
  def change
    add_column :journey_queries, :origin_geo_id, :string
    add_column :journey_queries, :destination_geo_id, :string
  end
end
