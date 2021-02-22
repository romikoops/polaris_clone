# frozen_string_literal: true
class AddCurrencyToResultSet < ActiveRecord::Migration[5.2]
  def change
    add_column :journey_result_sets, :currency, :string, null: false

    safety_assured do
      add_presence_constraint :journey_result_sets, :currency
    end
  end
end
