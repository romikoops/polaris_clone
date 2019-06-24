# frozen_string_literal: true

class CreateLegacyCargoItemTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_cargo_item_types, id: :uuid, &:timestamps
  end
end
