# frozen_string_literal: true

class CreateDistributionsActions < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL.squish
        CREATE TYPE distributions_action_type AS ENUM ('add_fee', 'duplicate', 'adjust_fee', 'add_values');
      SQL
    end
    create_table :distributions_actions, id: :uuid do |t|
      t.references :organization, type: :uuid, index: true,
        foreign_key: { to_table: "organizations_organizations", on_delete: :cascade },
        dependent: :destroy
      t.references :target_organization, type: :uuid, index: true,
        foreign_key: { to_table: "organizations_organizations", on_delete: :cascade },
        dependent: :destroy
      t.column :action_type, :distributions_action_type
      t.string :upload_schema, index: true, null: false
      t.jsonb :where, default: {}
      t.jsonb :arguments, default: {}
      t.integer :order, null: false, default: 1, index: { unique: { scope: %i[organization_id target_organization_id] } }
      t.timestamps
    end
  end

  def down
    drop_table :distributions_actions

    safety_assured do
      execute <<-SQL.squish
        DROP TYPE distributions_action_type;
      SQL
    end
  end
end
