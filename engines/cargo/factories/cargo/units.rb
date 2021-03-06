# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_unit, class: "Cargo::Unit" do
    quantity { 2 }
    weight_value { 3000 }
    cargo_class { "00" }
    cargo_type { "GP" }
    goods_value_cents { 1_000 }
    goods_value_currency { :usd }
    association :organization, factory: :organizations_organization
    association :cargo, factory: :cargo_cargo

    before(:build) do |unit|
      next if unit.legacy.blank?

      unit.weight_value = unit.legacy.payload_in_kg
      next unless unit.cargo_class_00?

      unit.height_value = unit.legacy.height / 100.0
      unit.width_value = unit.legacy.width / 100.0
      unit.length_value = unit.legacy.length / 100.0
    end

    trait :fcl do
    end

    trait :lcl do
      width_value { 1.20 }
      length_value { 0.80 }
      height_value { 1.40 }
      weight_value { 500 }
      quantity { 1 }
      cargo_class { "00" }
      cargo_type { "LCL" }
    end

    trait :aggregated do
      volume_value { 1.3 }
      cargo_class { "00" }
      cargo_type { "AGR" }
      stackable { true }
    end

    trait :fcl_20 do
      cargo_class { "22" }
    end

    trait :fcl_40 do
      cargo_class { "42" }
    end

    trait :fcl_40_hq do
      cargo_class { "45" }
    end

    trait :fcl_45 do
      cargo_class { "L2" }
    end

    factory :lcl_unit, traits: %i[lcl]
    factory :aggregated_unit, traits: %i[aggregated]
    factory :fcl_20_unit, traits: %i[fcl fcl_20]
    factory :fcl_40_unit, traits: %i[fcl fcl_40]
    factory :fcl_40_hq_unit, traits: %i[fcl fcl_40_hq]
    factory :fcl_45_unit, traits: %i[fcl fcl_45]
  end
end

# == Schema Information
#
# Table name: cargo_units
#
#  id                   :uuid             not null, primary key
#  cargo_class          :bigint           default("00")
#  cargo_type           :bigint           default("LCL")
#  dangerous_goods      :integer          default("unspecified")
#  goods_value_cents    :integer          default(0), not null
#  goods_value_currency :string           not null
#  height_unit          :string           default("m")
#  height_value         :decimal(100, 4)  default(0.0)
#  legacy_type          :string
#  length_unit          :string           default("m")
#  length_value         :decimal(100, 4)  default(0.0)
#  quantity             :integer          default(0)
#  stackable            :boolean          default(FALSE)
#  volume_unit          :string           default("m3")
#  volume_value         :decimal(100, 6)  default(0.0)
#  weight_unit          :string           default("kg")
#  weight_value         :decimal(100, 3)  default(0.0)
#  width_unit           :string           default("m")
#  width_value          :decimal(100, 4)  default(0.0)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  cargo_id             :uuid
#  legacy_id            :integer
#  organization_id      :uuid
#  tenant_id            :uuid
#
# Indexes
#
#  index_cargo_units_on_cargo_class                (cargo_class)
#  index_cargo_units_on_cargo_id                   (cargo_id)
#  index_cargo_units_on_cargo_type                 (cargo_type)
#  index_cargo_units_on_legacy_type_and_legacy_id  (legacy_type,legacy_id)
#  index_cargo_units_on_tenant_id                  (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (cargo_id => cargo_cargos.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
