# frozen_string_literal: true

class ChangeQuotationIdToBeUuidInTenders < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :quotations_tenders, :quotation_id, :bigint }
    add_reference :quotations_tenders, :quotation, foreign_key: {to_table: :quotations_quotations},
                                                   type: :uuid, index: false
  end
end
