# frozen_string_literal: true

class AddCurrencyAndStatusToQuery < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    safety_assured do
      add_column :journey_queries, :status, :journey_status
      add_column :journey_queries, :currency, :string
    end
  end
end
