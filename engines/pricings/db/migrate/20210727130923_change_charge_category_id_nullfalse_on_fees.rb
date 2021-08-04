# frozen_string_literal: true

class ChangeChargeCategoryIdNullfalseOnFees < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_column_null :pricings_fees, :charge_category_id, false
    end
  end
end
