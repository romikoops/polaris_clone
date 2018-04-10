class AddTenantToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :tenant_id, :integer
  end
end
