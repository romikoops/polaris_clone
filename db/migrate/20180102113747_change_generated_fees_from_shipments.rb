# frozen_string_literal: true

class ChangeGeneratedFeesFromShipments < ActiveRecord::Migration[5.1]
  def change
    rename_column :shipments, :generated_fees, :schedules_charges
  end
end
