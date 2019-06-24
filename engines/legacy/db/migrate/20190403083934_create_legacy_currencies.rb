# frozen_string_literal: true

class CreateLegacyCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_currencies, id: :uuid, &:timestamps
  end
end
