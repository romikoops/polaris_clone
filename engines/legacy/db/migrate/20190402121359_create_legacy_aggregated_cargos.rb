# frozen_string_literal: true

class CreateLegacyAggregatedCargos < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_aggregated_cargos, id: :uuid, &:timestamps
  end
end
