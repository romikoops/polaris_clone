# frozen_string_literal: true

class AddOriginalPriceToTender < ActiveRecord::Migration[5.2]
  def change
    add_monetize :quotations_tenders,
                 :original_amount,
                 amount: { null: true, default: nil },
                 currency: { null: true, default: nil }
  end
end
