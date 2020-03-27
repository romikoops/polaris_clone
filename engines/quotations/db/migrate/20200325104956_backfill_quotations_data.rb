# frozen_string_literal: true

class BackfillQuotationsData < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    Legacy::ChargeBreakdown.where.not(tender_id: nil).find_each do |charge_breakdown|
      tender = charge_breakdown.tender
      shipment = charge_breakdown.shipment
      next if shipment.nil?

      quotation = tender.quotation
      quotation.pickup_address_id = shipment.trucking.dig('pre_carriage', 'address_id')
      quotation.delivery_address_id = shipment.trucking.dig('on_carriage', 'address_id')
      quotation.save

      if charge_breakdown.trip.present? && tender.itinerary_id.nil?
        tender.update(itinerary_id: charge_breakdown.trip.itinerary_id)
      end
      tender.line_items.where(section: nil).find_each do |line_item|
        charge = charge_breakdown.charges.find_by(children_charge_category: line_item.charge_category)
        line_item_section = "#{charge.parent.charge_category.code}_section".to_sym
        line_item.update(section: line_item_section)
      end
    end
  end
end
