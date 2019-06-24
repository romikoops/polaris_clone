# frozen_string_literal: true

class CreateLegacyLayovers < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_layovers, id: :uuid, &:timestamps
  end
end
