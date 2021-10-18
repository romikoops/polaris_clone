# frozen_string_literal: true

class RemoveNotNullFromPreferredVoyage < ActiveRecord::Migration[5.2]
  def up
    change_column_null(:journey_shipment_requests, :preferred_voyage, true)
    safety_assured do
      execute("ALTER TABLE journey_shipment_requests DROP CONSTRAINT journey_shipment_requests_preferred_voyage_presence;")
    end
  end

  def down; end
end
