# frozen_string_literal: true

class AddIndexToLocalChargesUuid < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_statement_timeout(5000)

  def change
    add_index(:local_charges, :uuid, algorithm: :concurrently)
  end
end
