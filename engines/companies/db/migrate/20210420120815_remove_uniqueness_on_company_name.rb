# frozen_string_literal: true

class RemoveUniquenessOnCompanyName < ActiveRecord::Migration[5.2]
  def change
    remove_index :companies_companies, name: "index_companies_companies_on_organization_id_and_name"
  end
end
