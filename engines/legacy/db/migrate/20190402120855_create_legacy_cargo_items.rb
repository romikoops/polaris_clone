# frozen_string_literal: true

class CreateLegacyCargoItems < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_cargo_items, id: :uuid, &:timestamps
  end
end
