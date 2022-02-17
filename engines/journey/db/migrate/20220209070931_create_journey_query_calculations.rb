# frozen_string_literal: true

class CreateJourneyQueryCalculations < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_query_calculations, id: :uuid do |t|
      t.references :query, type: :uuid, index: true, foreign_key: { on_delete: :cascade, to_table: "journey_queries" }
      t.column :status, :journey_status, index: true
      t.boolean :pre_carriage, null: false
      t.boolean :on_carriage, null: false
      t.timestamps
    end
  end
end
