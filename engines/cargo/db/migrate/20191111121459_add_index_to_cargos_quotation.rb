# frozen_string_literal: true

class AddIndexToCargosQuotation < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :cargo_cargos, :quotation_id, algorithm: :concurrently
  end
end
