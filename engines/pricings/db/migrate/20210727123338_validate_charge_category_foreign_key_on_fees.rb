# frozen_string_literal: true

class ValidateChargeCategoryForeignKeyOnFees < ActiveRecord::Migration[5.2]
  set_statement_timeout(15_000)

  def change
    validate_foreign_key :pricings_fees, :charge_categories
  end
end
