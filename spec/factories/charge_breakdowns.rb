# frozen_string_literal: true

FactoryBot.define do
  factory :charge_breakdown do
    association :shipment
    association :freight_tenant_vehicle, factory: :tenant_vehicle
    valid_until { 4.days.from_now.beginning_of_day }

    transient do
      charge_category_name { 'Cargo' }
    end

    before(:create) do |charge_breakdown, evaluator|
      shipment = charge_breakdown.shipment
      charge_breakdown.update!(trip_id: shipment.trip_id) if charge_breakdown.trip_id.nil?
      cargo_units = shipment.aggregated_cargo.present? ? [shipment.aggregated_cargo] : shipment.cargo_units
      if charge_breakdown.charges.empty?
        cargo_charge_category = ChargeCategory.find_by(
          name: evaluator.charge_category_name,
          code: evaluator.charge_category_name.underscore,
          organization_id: shipment.organization_id
        ) || create(:charge_category,
                    name: evaluator.charge_category_name,
                    code: evaluator.charge_category_name.underscore,
                    organization_id: shipment.organization_id)
        cargo_units.each do |cargo_unit|
          cargo_unit_charge_category = ChargeCategory.find_by(
            name: cargo_unit.class.name.humanize,
            code: cargo_unit.class.name.underscore.downcase,
            cargo_unit_id: cargo_unit[:id],
            organization_id: shipment.organization_id
          ) || create(:charge_category,
                      name: cargo_unit.class.name.humanize,
                      code: cargo_unit.class.name.underscore.downcase,
                      cargo_unit_id: cargo_unit[:id],
                      organization_id: shipment.organization_id)
          base_charge = build(
            :charge,
            charge_breakdown: charge_breakdown,
            charge_category: ChargeCategory.from_code(code: 'base_node', name: 'Base Node', organization_id: shipment.organization_id),
            children_charge_category: ChargeCategory.from_code(code: 'grand_total', name: 'Grand Total', organization_id: shipment.organization_id)
          )
          grand_total_charge = build(
            :charge,
            charge_breakdown: charge_breakdown,
            charge_category: ChargeCategory.from_code(code: 'grand_total', name: 'Grand Total', organization_id: shipment.organization_id),
            children_charge_category: cargo_charge_category,
            parent_id: base_charge.id
          )
          cargo_charge = build(
            :charge,
            charge_breakdown: charge_breakdown,
            charge_category: cargo_charge_category,
            children_charge_category: cargo_unit_charge_category,
            parent_id: grand_total_charge.id
          )
          cargo_unit_charge = build(
            :charge,
            charge_breakdown: charge_breakdown,
            charge_category: cargo_unit_charge_category,
            parent_id: cargo_charge.id
          )

          charge_breakdown.charges << base_charge
          charge_breakdown.charges << grand_total_charge
          charge_breakdown.charges << cargo_charge
          charge_breakdown.charges << cargo_unit_charge
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
