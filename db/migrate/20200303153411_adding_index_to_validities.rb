# frozen_string_literal: true

class AddingIndexToValidities < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :pricings, :validity, using: :gist, algorithm: :concurrently, name: 'legacy_pricings_validity_index'
    add_index :local_charges, :validity, using: :gist, algorithm: :concurrently
  end
end
