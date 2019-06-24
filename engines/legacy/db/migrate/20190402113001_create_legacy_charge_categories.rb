# frozen_string_literal: true

class CreateLegacyChargeCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_charge_categories, id: :uuid, &:timestamps
  end
end
