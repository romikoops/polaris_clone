class CreateDefaultGroups < ActiveRecord::Migration[5.2]
  def change
    sql = <<~SQL
      INSERT INTO groups_groups (name, organization_id, created_at, updated_at)
      SELECT
        'default',
        organizations_organizations.id AS org,
        organizations_organizations.created_at,
        organizations_organizations.created_at
      FROM organizations_organizations
      WHERE NOT EXISTS (SELECT 1 FROM groups_groups WHERE name = 'default' AND organization_id = organizations_organizations.id );
    SQL

    safety_assured do
      execute(sql)
    end
  end
end
