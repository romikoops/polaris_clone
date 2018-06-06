# frozen_string_literal: true

class AddClosingDateToLayover < ActiveRecord::Migration[5.1]
  def change
    add_column :layovers, :closing_date, :datetime
  end
end
