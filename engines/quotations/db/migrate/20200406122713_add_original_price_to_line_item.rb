# frozen_string_literal: true

class AddOriginalPriceToLineItem < ActiveRecord::Migration[5.2]
  def change
    add_monetize :quotations_line_items,
                 :original_amount,
                 amount: { null: true, default: nil },
                 currency: { null: true, default: nil }
  end
end
