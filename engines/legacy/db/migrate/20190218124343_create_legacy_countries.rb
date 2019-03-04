# frozen_string_literal: true

class CreateLegacyCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_countries, id: :uuid, &:timestamps
  end
end
