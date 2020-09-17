class AddTenantsGroupIdToGroups < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      add_column :groups_groups, :tenants_group_id, :uuid

      add_index :groups_groups, :tenants_group_id, using: "btree"
    end
  end
end
