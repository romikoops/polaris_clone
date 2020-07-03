# frozen_string_literal: true

class CreateCompaniesCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies_companies, id: :uuid do |t|
      t.string :email
      t.string :phone
      t.string :name
      t.string :vat_number
      t.references :address, type: :integer, foreign_key: {to_table: :addresses}
      t.references :organization, type: :uuid, foreign_key: {to_table: :organizations_organizations}
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
