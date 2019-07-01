# frozen_string_literal: true

class AddInternalFlagToPricings < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings, :internal, :boolean, index: true
    change_column_default :pricings, :internal, false
  end
end
