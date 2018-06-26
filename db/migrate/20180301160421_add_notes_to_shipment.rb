# frozen_string_literal: true

class AddNotesToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :notes, :string
  end
end
