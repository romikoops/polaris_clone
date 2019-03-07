# frozen_string_literal: true

class CreateLegacyAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_addresses, id: :uuid, &:timestamps
  end
end
