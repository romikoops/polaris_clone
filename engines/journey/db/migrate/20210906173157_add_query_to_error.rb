# frozen_string_literal: true

class AddQueryToError < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :journey_errors, :query, foreign_key: { to_table: :journey_queries }, type: :uuid
    end
  end
end
