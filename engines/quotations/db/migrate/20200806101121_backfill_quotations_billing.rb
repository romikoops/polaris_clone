class BackfillQuotationsBilling < ActiveRecord::Migration[5.2]
  def up
    exec_update <<~SQL
      UPDATE quotations_quotations
      SET billing = shipments.billing
      FROM shipments
      WHERE quotations_quotations.legacy_shipment_id = shipments.id
    SQL
  end
end
