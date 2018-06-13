# frozen_string_literal: true

class AddClosingDateToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :closing_date, :datetime
  end
end
