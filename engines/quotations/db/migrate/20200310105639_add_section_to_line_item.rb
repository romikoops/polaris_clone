# frozen_string_literal: true

class AddSectionToLineItem < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_line_items, :section, :integer, index: true
  end
end
