# frozen_string_literal: true
class CreateJourneyResultSets < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_result_sets, id: :uuid do |t|
      t.references :query, type: :uuid, index: true,
                           foreign_key: {on_delete: :cascade, to_table: "journey_queries"}
      t.timestamps
    end
  end
end
