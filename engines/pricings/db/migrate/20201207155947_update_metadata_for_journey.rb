class UpdateMetadataForJourney < ActiveRecord::Migration[5.2]
  def change
    add_column :pricings_metadata, :result_id, :uuid, index: true
    add_column :pricings_breakdowns, :line_item_id, :uuid, index: true
  end
end
