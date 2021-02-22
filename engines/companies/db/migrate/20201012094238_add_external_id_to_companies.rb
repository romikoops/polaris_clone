# frozen_string_literal: true
class AddExternalIdToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies_companies, :external_id, :string
  end
end
