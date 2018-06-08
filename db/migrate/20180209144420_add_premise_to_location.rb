# frozen_string_literal: true

class AddPremiseToLocation < ActiveRecord::Migration[5.1]
  def change
    add_column :locations, :premise, :string
  end
end
