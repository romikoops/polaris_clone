# frozen_string_literal: true

FactoryBot.define do
  factory :charge_breakdown do
    association :shipment
    valid_until { 4.days.from_now.beginning_of_day }

    transient do
      charge_category_name { 'Cargo' }
    end

    before(:create) do |charge_breakdown, evaluator|
      charge_breakdown.update!(trip_id: charge_breakdown.shipment.trip_id) if charge_breakdown.trip_id.nil?

      if charge_breakdown.charges.empty?
        cargo_charge_category = ChargeCategory.find_by(
          name: evaluator.charge_category_name,
          code: evaluator.charge_category_name.underscore,
          tenant_id: charge_breakdown.shipment.tenant_id
        ) || create(:charge_category,
                    name: evaluator.charge_category_name,
                    code: evaluator.charge_category_name.underscore,
                    tenant_id: charge_breakdown.shipment.tenant_id)
        charge_breakdown.shipment.cargo_units. each do |cargo_unit|
          cargo_unit_charge_category = ChargeCategory.find_by(
            name: cargo_unit.class.name.humanize,
            code: cargo_unit.class.name.underscore.downcase,
            cargo_unit_id: cargo_unit[:id],
            tenant_id: charge_breakdown.shipment.tenant_id
          ) || create(:charge_category,
                      name: cargo_unit.class.name.humanize,
                      code: cargo_unit.class.name.underscore.downcase,
                      cargo_unit_id: cargo_unit[:id],
                      tenant_id: charge_breakdown.shipment.tenant_id)
          base_charge = build(
            :charge,
            charge_breakdown: charge_breakdown,
            charge_category: ChargeCategory.base_node,
            children_charge_category: ChargeCategory.grand_total
          )
          grand_total_charge = build(
            :charge,
            charge_breakdown: charge_breakdown,
            charge_category: ChargeCategory.grand_total,
            children_charge_category: cargo_charge_category,
            parent: base_charge
          )
          cargo_charge = build(
            :charge,
            charge_breakdown: charge_breakdown,
            charge_category: cargo_charge_category,
            children_charge_category: cargo_unit_charge_category,
            parent: grand_total_charge
          )
          cargo_unit_charge = build(
            :charge,
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
#  valid_until :datetime
#
