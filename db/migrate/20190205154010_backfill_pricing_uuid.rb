# frozen_string_literal: true

class BackfillPricingUuid < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    Pricing.in_batches.update_all(uuid: SecureRandom.uuid)
  end
end
