# frozen_string_literal: true

class AddLineItemIdToLegacyCharge < ActiveRecord::Migration[5.2]
  def change
    add_reference :charges, :line_item, table: :quotations_line_items, type: :uuid, index: false
  end
end
