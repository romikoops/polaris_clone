# frozen_string_literal: true

class AddIncotermToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :incoterm, :string
  end
end
