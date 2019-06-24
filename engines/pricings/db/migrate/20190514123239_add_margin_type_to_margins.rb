# frozen_string_literal: true

class AddMarginTypeToMargins < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings_margins, :margin_type, :integer, index: true
  end
end
