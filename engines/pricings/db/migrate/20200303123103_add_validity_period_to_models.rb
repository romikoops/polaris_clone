# frozen_string_literal: true

class AddValidityPeriodToModels < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings_pricings, :validity, :daterange
    add_column :pricings_margins, :validity, :daterange
  end
end
