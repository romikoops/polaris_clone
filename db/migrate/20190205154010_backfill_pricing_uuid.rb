# frozen_string_literal: true

class BackfillPricingUuid < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      execute "UPDATE pricings SET uuid = gen_random_uuid() WHERE uuid IS NULL"
    end
  end
end
