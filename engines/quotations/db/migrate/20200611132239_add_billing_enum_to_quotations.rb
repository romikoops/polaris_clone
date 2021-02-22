# frozen_string_literal: true
class AddBillingEnumToQuotations < ActiveRecord::Migration[5.2]
  def up
    add_column :quotations_quotations, :billing, :integer, index: true
    change_column_default :quotations_quotations, :billing, 0
  end

  def down
    remove_column :quotations_quotations, :billing
  end
end
