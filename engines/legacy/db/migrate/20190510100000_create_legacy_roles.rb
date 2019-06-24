# frozen_string_literal: true

class CreateLegacyRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_roles, id: :uuid, &:timestamps
  end
end
