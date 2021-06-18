# frozen_string_literal: true

class AddImcReferenceToLineItemSet < ActiveRecord::Migration[5.2]
  def change
    add_column :journey_line_item_sets, :reference, :string
  end
end
