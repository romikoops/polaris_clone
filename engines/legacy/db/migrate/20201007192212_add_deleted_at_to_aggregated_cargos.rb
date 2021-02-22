# frozen_string_literal: true
class AddDeletedAtToAggregatedCargos < ActiveRecord::Migration[5.2]
  def change
    add_column :aggregated_cargos, :deleted_at, :datetime
  end
end
