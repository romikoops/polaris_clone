# frozen_string_literal: true

class BackfillRoutingConnections < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    TenantRouting::Connection.in_batches.update_all(mode_of_transport: 0)
  end
end
