# frozen_string_literal: true

class CreateOrganizationsOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations_organizations, id: :uuid do |t|
      t.string :slug, index: {unique: true}

      t.timestamps
    end
  end
end
