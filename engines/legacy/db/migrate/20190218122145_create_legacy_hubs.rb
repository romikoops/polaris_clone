# frozen_string_literal: true

class CreateLegacyHubs < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_hubs, id: :uuid, &:timestamps
  end
end
