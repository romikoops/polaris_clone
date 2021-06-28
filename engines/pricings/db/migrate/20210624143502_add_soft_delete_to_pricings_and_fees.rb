# frozen_string_literal: true

class AddSoftDeleteToPricingsAndFees < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings_pricings, :deleted_at, :datetime
    add_column :pricings_fees, :deleted_at, :datetime
  end
end
