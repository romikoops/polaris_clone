# frozen_string_literal: true
class AddValidityToTrucking < ActiveRecord::Migration[5.2]
  def change
    add_column :trucking_truckings, :validity, :daterange
  end
end
