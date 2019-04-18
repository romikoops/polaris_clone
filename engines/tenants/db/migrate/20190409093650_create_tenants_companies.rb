class CreateTenantsCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants_companies, id: :uuid do |t|
      t.string :name
      t.integer :address_id
      t.string :vat_number
      t.string :email
      t.uuid :tenant_id
      t.timestamps
    end
  end
end
