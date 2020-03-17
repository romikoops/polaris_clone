# frozen_string_literal: true

class AddCarrierInfoToMaxDimensions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :max_dimensions_bundles, :carrier, index: { algorithm: :concurrently }
    add_reference :max_dimensions_bundles, :tenant_vehicle, index: { algorithm: :concurrently }
  end
end
