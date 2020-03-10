# frozen_string_literal: true

class AddingIndexToPricingValidities < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :pricings_pricings, :validity, using: :gist, algorithm: :concurrently
  end
end
