# frozen_string_literal: true
class CreateTenantRoutingVisibilities < ActiveRecord::Migration[5.2]
  def change
    create_table :tenant_routing_visibilities, id: :uuid do |t|
      t.references :target, polymorphic: true, type: :uuid, index: {name: "visibility_target_index"}
      t.uuid :connection_id, index: {name: "visibility_connection_index"}
      t.timestamps
    end
  end
end
