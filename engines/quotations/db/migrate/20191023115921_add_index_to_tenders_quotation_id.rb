# frozen_string_literal: true

class AddIndexToTendersQuotationId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :quotations_tenders, :quotation_id, algorithm: :concurrently
  end
end
