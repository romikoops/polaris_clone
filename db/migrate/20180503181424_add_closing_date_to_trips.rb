# frozen_string_literal: true

class AddClosingDateToTrips < ActiveRecord::Migration[5.1]
  def change
    add_column :trips, :closing_date, :datetime
  end
end
