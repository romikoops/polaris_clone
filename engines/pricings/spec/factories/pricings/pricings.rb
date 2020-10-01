# frozen_string_literal: true

FactoryBot.define do
  factory :pricings_pricing, class: 'Pricings::Pricing' do
    wm_rate { 1000 }
    transient do
      fee_attrs { nil }
      amount { 250 }
      default_group do
        Groups::Group.find_by(organization: organization, name: 'default') ||
          FactoryBot.create(:groups_group, organization: organization, name: 'default')
      end
    end

    effective_date { Time.zone.today }
    expiration_date { 6.months.from_now }
    cargo_class { 'lcl' }
    load_type { 'cargo_item' }
    group_id { default_group.id }

    association :organization, factory: :organizations_organization
    association :itinerary, :default, factory: :legacy_itinerary
    association :tenant_vehicle, factory: :legacy_tenant_vehicle

    after :create do |pricing, evaluator|
      next unless evaluator.fee_attrs

      fee_options = { pricing: pricing,
                      organization_id: pricing.organization_id,
                      rate_basis: FactoryBot.create(evaluator.fee_attrs[:rate_basis]) }
      fee_options.merge!(evaluator.fee_attrs.except(:rate_basis))
      create_list :pricings_fee, 1, **fee_options
    end

    trait :lcl do
      cargo_class { 'lcl' }
      load_type { 'cargo_item' }
      after :create do |pricing|
        create_list(:pricings_fee,
                    1,
                    pricing: pricing,
                    organization_id: pricing.organization_id,
                    rate_basis: FactoryBot.create(:per_wm_rate_basis),
                    rate: 25,
                    charge_category: FactoryBot.create(:bas_charge, organization_id: pricing.organization_id))
      end
    end
    trait :fcl_20 do
      cargo_class { 'fcl_20' }
      load_type { 'container' }
      after :create do |pricing, evaluator|
        create_list(:pricings_fee,
                    1,
                    pricing: pricing,
                    organization_id: pricing.organization_id,
                    rate_basis: FactoryBot.create(:per_container_rate_basis),
                    rate: evaluator.amount,
                    charge_category: FactoryBot.create(:bas_charge, organization_id: pricing.organization_id))
      end
    end

    trait :fcl_40 do
      cargo_class { 'fcl_40' }
      load_type { 'container' }
      after :create do |pricing|
        create_list(:pricings_fee,
                    1,
                    pricing: pricing,
                    organization_id: pricing.organization_id,
                    rate_basis: FactoryBot.create(:per_container_rate_basis),
                    rate: 250,
                    charge_category: FactoryBot.create(:bas_charge, organization_id: pricing.organization_id))
      end
    end

    trait :fcl_40_hq do
      cargo_class { 'fcl_40_hq' }
      load_type { 'container' }
      after :create do |pricing|
        create_list(:pricings_fee,
                    1,
                    pricing: pricing,
                    organization_id: pricing.organization_id,
                    rate_basis: FactoryBot.create(:per_container_rate_basis),
                    rate: 250,
                    charge_category: FactoryBot.create(:bas_charge, organization_id: pricing.organization_id))
      end
    end

    trait :lcl_range do
      cargo_class { 'lcl' }
      load_type { 'cargo_item' }
      after :create do |pricing|
        create_list(:fee_per_kg_range,
                    1,
                    pricing: pricing,
                    organization_id: pricing.organization_id)
      end
    end

    trait :container_range do
      cargo_class { 'lcl' }
      load_type { 'cargo_item' }
      after :create do |pricing|
        create_list(:fee_per_container_range,
                    1,
                    pricing: pricing,
                    organization_id: pricing.organization_id)
      end
    end

    trait :fully_loaded_lcl do
      cargo_class { 'lcl' }
      load_type { 'cargo_item' }
      after :create do |pricing|
        create(:pricings_fee,
                  pricing: pricing,
                  organization_id: pricing.organization_id,
                  rate_basis: FactoryBot.create(:per_wm_rate_basis),
                  rate: 25,
                  charge_category: FactoryBot.create(:bas_charge, organization_id: pricing.organization_id))
        create(:fee_per_kg_range,
                  pricing: pricing,
                  organization_id: pricing.organization_id,
                  charge_category: FactoryBot.create(:solas_charge, organization_id: pricing.organization_id))
      end
    end

    factory :loaded_lcl_pricing, traits: [:fully_loaded_lcl]
    factory :lcl_pricing, traits: [:lcl]
    factory :lcl_range_pricing, traits: [:lcl_range]
    factory :container_range_pricing, traits: [:container_range]
    factory :fcl_20_pricing, traits: [:fcl_20]
    factory :fcl_40_pricing, traits: [:fcl_40]
    factory :fcl_40_hq_pricing, traits: [:fcl_40_hq]
  end
end

# == Schema Information
#
# Table name: pricings_pricings
#
#  id                :uuid             not null, primary key
#  cargo_class       :string
#  effective_date    :datetime
#  expiration_date   :datetime
#  internal          :boolean          default(FALSE)
#  load_type         :string
#  transshipment     :string
#  validity          :daterange
#  wm_rate           :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  group_id          :uuid
#  itinerary_id      :bigint
#  legacy_id         :integer
#  old_user_id       :bigint
#  organization_id   :uuid
#  sandbox_id        :uuid
#  tenant_id         :bigint
#  tenant_vehicle_id :integer
#  user_id           :uuid
#
# Indexes
#
#  index_pricings_pricings_on_cargo_class        (cargo_class)
#  index_pricings_pricings_on_group_id           (group_id)
#  index_pricings_pricings_on_itinerary_id       (itinerary_id)
#  index_pricings_pricings_on_load_type          (load_type)
#  index_pricings_pricings_on_old_user_id        (old_user_id)
#  index_pricings_pricings_on_organization_id    (organization_id)
#  index_pricings_pricings_on_sandbox_id         (sandbox_id)
#  index_pricings_pricings_on_tenant_id          (tenant_id)
#  index_pricings_pricings_on_tenant_vehicle_id  (tenant_vehicle_id)
#  index_pricings_pricings_on_user_id            (user_id)
#  index_pricings_pricings_on_validity           (validity) USING gist
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
