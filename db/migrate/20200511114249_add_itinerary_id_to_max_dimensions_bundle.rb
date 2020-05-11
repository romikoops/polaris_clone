# frozen_string_literal: true

class AddItineraryIdToMaxDimensionsBundle < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :max_dimensions_bundles, :itinerary, index: { algorithm: :concurrently }
  end
end
