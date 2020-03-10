# frozen_string_literal: true

class AddingValidityToLegacyModels < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings, :validity, :daterange
    add_column :local_charges, :validity, :daterange
  end
end
