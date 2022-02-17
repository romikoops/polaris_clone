# frozen_string_literal: true

class AddQueryCalculationToError < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :journey_errors, :query_calculation, foreign_key: { to_table: :journey_query_calculations }, type: :uuid
    end
  end
end
