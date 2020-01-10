# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_charge_breakdown, class: 'Legacy::ChargeBreakdown' do
    association :shipment, factory: :legacy_shipment

    before(:create) do |charge_breakdown|
      shipment = charge_breakdown.shipment

      charge_breakdown.update!(trip_id: shipment.trip_id) if charge_breakdown.trip_id.nil?
      cargo_units = shipment.aggregated_cargo.present? ? [shipment.aggregated_cargo] : shipment.cargo_units

      if charge_breakdown.charges.empty?
        cargo_charge_category = Legacy::ChargeCategory.find_by(
          name: 'Cargo',
          code: 'cargo',
          tenant_id: shipment.tenant_id

        ) || create(:legacy_charge_categories,
          name: 'Cargo',
          code: 'cargo',
          tenant_id: shipment.tenant_id)

        cargo_units.each do |cargo_unit|
          cargo_unit_charge_category = create(:legacy_charge_categories,
            name: cargo_unit.class.name.humanize,
            code: cargo_unit.class.name.underscore.downcase,
            cargo_unit_id: cargo_unit[:id],
            tenant_id: shipment.tenant_id)

          base_charge = create(
            :legacy_charge,
            charge_breakdown: charge_breakdown,
            charge_category: Legacy::ChargeCategory.base_node,
            children_charge_category: Legacy::ChargeCategory.grand_total
          )

          grand_total_charge = create(
            :legacy_charge,
            charge_breakdown: charge_breakdown,
            charge_category: Legacy::ChargeCategory.grand_total,
            children_charge_category: cargo_charge_category,
            parent: base_charge
          )

          cargo_charge = create(
            :legacy_charge,
            charge_breakdown: charge_breakdown,
            charge_category: cargo_charge_category,
            children_charge_category: cargo_unit_charge_category,
            parent: grand_total_charge
          )

          cargo_unit_charge = create(
            :legacy_charge,
            charge_breakdown: charge_breakdown,
            charge_category: cargo_unit_charge_category,
            parent: cargo_charge
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
#  id          :bigint           not null, primary key
#  shipment_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  trip_id     :integer
#  sandbox_id  :uuid
#
