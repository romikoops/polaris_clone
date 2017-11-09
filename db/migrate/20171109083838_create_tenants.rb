class CreateTenants < ActiveRecord::Migration[5.1]
  def change
    create_table :tenants do |t|
        t.jsonb :theme
        t.string :address
        t.string :phone
        t.jsonb :emails
        t.string :subdomain
      t.timestamps
    end
  end
end
