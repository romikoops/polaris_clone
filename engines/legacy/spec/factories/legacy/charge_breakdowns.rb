# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_charge_breakdown, class: 'Legacy::ChargeBreakdown' do
    association :shipment, factory: :legacy_shipment
    association :freight_tenant_vehicle, factory: :legacy_tenant_vehicle
    transient do
      with_tender { false }
      quotation { nil }
      sections { ['cargo'] }
    end

    before(:create) do |charge_breakdown, evaluator|
      shipment = charge_breakdown.shipment
      if (charge_breakdown.trip_id.nil? || charge_breakdown.freight_tenant_vehicle_id.nil?) && shipment.trip.present?
        charge_breakdown.update(trip_id: shipment.trip_id, freight_tenant_vehicle_id: shipment.trip.tenant_vehicle_id)
      end
      cargo_units = shipment.aggregated_cargo.present? ? [shipment.aggregated_cargo] : shipment.cargo_units
      cargo_unit_charge_category_code = if shipment.aggregated_cargo.present?
                                          'aggregated_cargo'
                                        else
                                          shipment.load_type
                                        end
      if evaluator.with_tender
        tender = FactoryBot.create(:quotations_tender,
                                   carrier_name: charge_breakdown.trip.tenant_vehicle.carrier&.name,
                                   load_type: shipment.load_type,
                                   origin_hub: charge_breakdown.trip.itinerary.hubs.first,
                                   destination_hub: charge_breakdown.trip.itinerary.hubs.last,
                                   tenant_vehicle: charge_breakdown.trip.tenant_vehicle,
                                   amount: charge_breakdown&.grand_total&.price&.money,
                                   quotation: evaluator.quotation)
        charge_breakdown.tender = tender
      end
      evaluator.sections.each do |section|
        section_charge_category = Legacy::ChargeCategory.find_by(
          code: section,
          organization_id: shipment.organization_id
        ) || create(:legacy_charge_categories,
                    name: section.humanize,
                    code: section,
                    organization_id: shipment.organization_id)

        base_charge = create(
          :legacy_charge,
          charge_breakdown: charge_breakdown,
          charge_category: Legacy::ChargeCategory.from_code(
            code: 'base_node', name: 'Base Node', organization_id: shipment.organization_id
          ),
          children_charge_category: Legacy::ChargeCategory.from_code(
            code: 'grand_total', name: 'Grand Total', organization_id: shipment.organization_id
          )
        )

        grand_total_charge = create(
          :legacy_charge,
          charge_breakdown: charge_breakdown,
          charge_category: Legacy::ChargeCategory.from_code(
            code: 'grand_total', name: 'Grand Total', organization_id: shipment.organization_id
          ),
          children_charge_category: section_charge_category,
          parent_id: base_charge.id,
          detail_level: 1
        )

        cargo_units.each do |cargo_unit|
          cargo_unit_charge_category = create(:legacy_charge_categories,
                                              name: cargo_unit_charge_category_code.humanize,
                                              code: cargo_unit_charge_category_code,
                                              cargo_unit_id: cargo_unit[:id],
                                              organization_id: shipment.organization_id)

          cargo_charge = create(
            :legacy_charge,
            charge_breakdown: charge_breakdown,
            charge_category: section_charge_category,
            children_charge_category: cargo_unit_charge_category,
            parent_id: grand_total_charge.id,
            detail_level: 2
          )

          cargo_unit_charge = create(
            :legacy_charge,
            charge_breakdown: charge_breakdown,
            charge_category: cargo_unit_charge_category,
            parent_id: cargo_charge.id,
            detail_level: 3,
            children_charge_category: create(:legacy_charge_categories,
                                             name: 'Basic Freight',
                                             code: 'bas',
                                             organization_id: shipment.organization_id)
          )
          if evaluator.with_tender
            FactoryBot.create(:quotations_line_item,
                              amount: cargo_unit_charge.price.money,
                              tender: tender,
                              cargo: cargo_unit,
                              charge_category: cargo_unit_charge.children_charge_category,
                              section: "#{section}_section".to_sym)
          end

          charge_breakdown.charges << cargo_charge
          charge_breakdown.charges << cargo_unit_charge
        end
        if evaluator.with_tender
          line_item_total = tender.line_items.sum(&:amount)
          tender.update(amount: line_item_total, original_amount: line_item_total)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: charge_breakdowns
#
#  id                         :bigint           not null, primary key
#  valid_until                :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  delivery_tenant_vehicle_id :integer
#  freight_tenant_vehicle_id  :integer
#  pickup_tenant_vehicle_id   :integer
#  sandbox_id                 :uuid
#  shipment_id                :integer
#  tender_id                  :uuid
#  trip_id                    :integer
#
# Indexes
#
#  index_charge_breakdowns_on_delivery_tenant_vehicle_id  (delivery_tenant_vehicle_id)
#  index_charge_breakdowns_on_freight_tenant_vehicle_id   (freight_tenant_vehicle_id)
#  index_charge_breakdowns_on_pickup_tenant_vehicle_id    (pickup_tenant_vehicle_id)
#  index_charge_breakdowns_on_sandbox_id                  (sandbox_id)
#
# Foreign Keys
#
#  fk_rails_...  (delivery_tenant_vehicle_id => tenant_vehicles.id)
#  fk_rails_...  (freight_tenant_vehicle_id => tenant_vehicles.id)
#  fk_rails_...  (pickup_tenant_vehicle_id => tenant_vehicles.id)
#
