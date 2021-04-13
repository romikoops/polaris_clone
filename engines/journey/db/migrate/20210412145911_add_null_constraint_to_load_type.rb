# frozen_string_literal: true

class AddNullConstraintToLoadType < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      change_column_null :journey_queries, :load_type, false
    end
  end
end
