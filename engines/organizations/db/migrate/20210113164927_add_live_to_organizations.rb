class AddLiveToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations_organizations, :live, :boolean
    change_column_default :organizations_organizations, :live, false
  end
end
