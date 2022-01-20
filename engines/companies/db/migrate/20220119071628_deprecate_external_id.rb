# frozen_string_literal: true

class DeprecateExternalId < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      # rubocop:disable Naming/VariableNumber
      rename_column :companies_companies, :external_id, :external_id_20220118
      # rubocop:enable Naming/VariableNumber
    end
  end
end
