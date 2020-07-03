class AddTenantsCompanyIdToCompanies < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :companies_companies, :tenants_company_id, :uuid

      add_index :companies_companies, :tenants_company_id, using: 'btree'
    end
  end
end
