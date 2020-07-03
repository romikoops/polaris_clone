# frozen_string_literal: true

class CreateOrganizationsDomains < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations_domains, id: :uuid do |t|
      t.string :domain, index: {unique: true}
      t.references :organization, index: true, foreign_key: {to_table: :organizations_organizations}, type: :uuid
      t.boolean :default, null: false, default: false

      t.string :aliases, array: true

      t.timestamps
    end
  end
end
