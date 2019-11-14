# frozen_string_literal: true

class AddQuotationToCargos < ActiveRecord::Migration[5.2]
  def change
    add_reference :cargo_cargos, :quotation, foreign_key: { to_table: :quotations_quotations },
                                             type: :uuid, index: false
  end
end
