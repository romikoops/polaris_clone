# frozen_string_literal: true

class BackfillChargeBreakdownValidUntil < ActiveRecord::Migration[5.2]
  def change
    ChargeBreakdown.where(valid_until: nil).find_each do |charge_breakdown|
      shipment = charge_breakdown.shipment
      next if shipment.blank?

      user = shipment.user
      next if user.blank?

      trip = shipment.trip
      next if trip.blank?

      base_pricing_enabled = Tenants::ScopeService.new(
        target: Tenants::User.find_by(legacy_id: user.id),
        tenant: Tenants::Tenant.find_by(legacy_id: user.tenant_id)
      ).fetch(:base_pricing)
      cargo_classes = shipment.cargo_units.pluck(:cargo_class)
      start_date = shipment.planned_etd || shipment.desired_start_date || shipment.booking_placed_at
      end_date = shipment.planned_eta || shipment.desired_start_date || shipment.booking_placed_at
      target_itinerary = trip.itinerary
      pricing_association = base_pricing_enabled ? target_itinerary.rates : target_itinerary.pricings
      pricing_association = pricing_association.for_cargo_classes(cargo_classes)
                                               .for_dates(start_date, end_date)
                                               .where(
                                                 tenant_vehicle_id: trip.tenant_vehicle_id
                                               )

      dedicated = if base_pricing_enabled
                    pricing_association.where(group_id: user.all_groups.ids)
                  else
                    pricing_association.where(user_id: user.pricing_id)
                  end
      final_pricings = dedicated.presence || pricing_association.where(user_id: nil)

      valid_until_date = final_pricings.order(expiration_date: :asc).first&.expiration_date
      charge_breakdown.update(valid_until: valid_until_date) if valid_until_date.present?
    end
  end
end
