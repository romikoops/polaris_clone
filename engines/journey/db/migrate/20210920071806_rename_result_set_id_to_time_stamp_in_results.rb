# frozen_string_literal: true

class RenameResultSetIdToTimeStampInResults < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      remove_foreign_key :results, column: :result_set_id if foreign_key_exists?(:journey_results, :journey_result_set)
      remove_index :journey_results, name: "index_journey_results_on_result_set_id"
      rename_column(:journey_results, :result_set_id, :result_set_id_20210922)
    end
  end
end
