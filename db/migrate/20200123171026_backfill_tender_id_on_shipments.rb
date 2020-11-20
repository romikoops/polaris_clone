# frozen_string_literal: true

class BackfillTenderIdOnShipments < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    quotations_cutoff = DateTime.new(2019, 11, 25, 14, 31, 47, "+0100")
    safety_assured do
      execute <<-SQL
      UPDATE shipments SET tender_id = (meta ->> 'tender_id')::uuid
      WHERE tender_id is null AND ((meta -> 'tender_id') is not null)
      SQL
    end

    Legacy::Shipment.where(status: "quoted", tender_id: nil)
      .where.not(trip_id: nil)
      .where("created_at > ?", quotations_cutoff)
      .find_in_batches do |shipments|
      shipments.each do |shipment|
        next if shipment.trip.nil?

        total = shipment.total_price
        tenders = Quotations::Tender.joins(:quotation)
          .where(
            amount_cents: total[:value].round(2, half: :up) * 100,
            destination_hub_id: shipment.destination_hub_id,
            origin_hub_id: shipment.origin_hub_id,
            tenant_vehicle_id: shipment.trip.tenant_vehicle_id,
            quotations_quotations: {user_id: shipment.user_id}
          )
          .where(
            "quotations_tenders.created_at BETWEEN ? AND ?",
            shipment.created_at - 1.minute,
            shipment.created_at + 5.seconds
          )
        next if tenders.blank?

        shipment.update_columns(tender_id: tenders.first.id)
      end
    end
  end
end
