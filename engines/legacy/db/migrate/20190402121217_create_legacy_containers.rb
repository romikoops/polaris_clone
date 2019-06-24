# frozen_string_literal: true

class CreateLegacyContainers < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_containers, id: :uuid, &:timestamps
  end
end
