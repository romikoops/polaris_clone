# frozen_string_literal: true

class BackfillMetaDefault < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    Shipment.in_batches.update_all meta: {}
  end
end
