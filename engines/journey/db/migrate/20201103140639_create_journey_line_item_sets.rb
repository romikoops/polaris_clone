class CreateJourneyLineItemSets < ActiveRecord::Migration[5.2]
  def change
    create_table :journey_line_item_sets, id: :uuid do |t|
      t.references :shipment_request, type: :uuid, index: true,
                                      foreign_key: {on_delete: :cascade, to_table: "journey_shipment_requests"}
      t.references :result, type: :uuid, index: true,
                            foreign_key: {on_delete: :cascade, to_table: "journey_results"}
      t.timestamps
    end
  end
end
