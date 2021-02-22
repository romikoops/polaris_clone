# frozen_string_literal: true
class CreateJourneyResults < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_results, id: :uuid do |t|
      t.references :result_set, type: :uuid, index: true,
                                foreign_key: {on_delete: :cascade, to_table: "journey_result_sets"}
      t.datetime :expiration_date, null: false
      t.datetime :issued_at, null: false
      t.timestamps
    end
  end
end
