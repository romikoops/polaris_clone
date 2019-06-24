# frozen_string_literal: true

class CreateLegacyLocalCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_local_charges, id: :uuid, &:timestamps
  end
end
