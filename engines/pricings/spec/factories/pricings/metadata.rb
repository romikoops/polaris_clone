FactoryBot.define do
  factory :pricings_metadatum, class: 'Pricings::Metadatum' do
    association :tenant, factory: :tenants_tenant
    association :charge_breakdown, factory: :legacy_charge_breakdown

    after(:create) do |metadatum|
      cargo_units = metadatum.charge_breakdown.shipment.cargo_units
      metadatum.charge_breakdown.charges.where(detail_level: 3).map do |charge|
        charge_category = charge.children_charge_category
        metadatum.breakdowns << build(:pricings_breakdown,
          charge: charge,
          charge_category: charge_category,
          cargo_unit_id: charge_category.cargo_unit_id,
          cargo_unit_type: cargo_units.find_by(id: charge_category.cargo_unit_id)&.class&.to_s
        )
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings_metadata
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  cargo_unit_id       :integer
#  charge_breakdown_id :integer
#  pricing_id          :uuid
#  tenant_id           :uuid
#
# Indexes
#
#  index_pricings_metadata_on_charge_breakdown_id  (charge_breakdown_id)
#  index_pricings_metadata_on_tenant_id            (tenant_id)
#
