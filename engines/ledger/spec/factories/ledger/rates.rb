# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_rate, class: 'Ledger::Rate' do
    association :location, factory: :routing_location
    association :tenant, factory: :tenants_tenant
    association :target, factory: :routing_route_line_service

    transient do
      varied_dates { false }
      start { true }
      random { false }
      load_meterage_limit { nil }
      load_meterage_type { nil }
      load_meterage_ratio { nil }
      load_meterage_logic { nil }
    end

    trait :everything_lcl do
      after(:build) do |rate, evaluator|
        %i(range_kg_fee
           range_km_fee
           range_unit_fee
           range_cbm_fee
           range_stowage_fee
           km_fee
           unit_fee
           kg_fee
           wm_fee
           cbm_fee
           x_kg_fee
           range_x_kg_fee
           section_percentage_fee
           shipment_percentage_fee
           max_shipment_fee
           cbm_ton_fee).each do |key|
          rate.fees << build(key, :cargo_item, varied_dates: evaluator.varied_dates, start: evaluator.start, random: evaluator.random)
        end
      end
    end

    trait :everything_fcl do
      after(:build) do |rate, evaluator|
        %i(range_kg_fee
           range_km_fee
           range_unit_fee
           km_fee
           unit_fee
           kg_fee
           x_kg_fee
           range_x_kg_fee).each do |key|
          rate.fees << build(key, :container_20, varied_dates: evaluator.varied_dates, start: evaluator.start, random: evaluator.random)
        end
      end
    end

    trait :freight do
      location_id { nil }
      terminal_id { nil }
    end

    trait :lcl_default do
      after(:build) do |rate, evaluator|
        rate.fees << build(:cargo_item_fee,
                           varied_dates: evaluator.varied_dates,
                           start: evaluator.start,
                           random: evaluator.random,
                           load_meterage_limit: evaluator.load_meterage_limit,
                           load_meterage_type: evaluator.load_meterage_type,
                           load_meterage_ratio: evaluator.load_meterage_ratio,
                           load_meterage_logic: evaluator.load_meterage_logic)
      end
    end

    trait :air_default do
      after(:build) do |rate, evaluator|
        rate.fees << build(:range_kg_fee, varied_dates: evaluator.varied_dates, start: evaluator.start, random: evaluator.random)
      end
    end

    trait :fcl_default do
      after(:build) do |rate, evaluator|
        rate.fees << build(:container_fee, varied_dates: evaluator.varied_dates, start: evaluator.start, random: evaluator.random)
      end
    end

    trait :lcl_carriage_default do
      after(:build) do |rate, evaluator|
        rate.fees << build(:cargo_item_carriage_kg,
                           varied_dates: evaluator.varied_dates,
                           start: evaluator.start,
                           random: evaluator.random,
                           load_meterage_limit: evaluator.load_meterage_limit,
                           load_meterage_type: evaluator.load_meterage_type,
                           load_meterage_ratio: evaluator.load_meterage_ratio,
                           load_meterage_logic: evaluator.load_meterage_logic)
      end
    end

    trait :container_20_carriage_default do
      after(:build) do |rate, evaluator|
        rate.fees << build(:container_20_fee,
                           varied_dates: evaluator.varied_dates,
                           start: evaluator.start,
                           random: evaluator.random,
                           load_meterage_limit: evaluator.load_meterage_limit,
                           load_meterage_type: evaluator.load_meterage_type,
                           load_meterage_ratio: evaluator.load_meterage_ratio,
                           load_meterage_logic: evaluator.load_meterage_logic)
      end
    end

    factory :everything_rate, traits: [:everything_lcl]
    factory :freight_rate, traits: [:freight]
    factory :lcl_rate, traits: %i(lcl_default freight)
    factory :air_rate, traits: %i(air_default freight)
    factory :fcl_rate, traits: %i(fcl_default freight)
    factory :lcl_carriage_rate, traits: %i(lcl_carriage_default freight)
    factory :container_20_carriage_rate, traits: %i(container_20_carriage_default freight)
    factory :lcl_local_charge, traits: [:everything_lcl]
    factory :fcl_local_charge, traits: [:everything_fcl]
  end
end

# == Schema Information
#
# Table name: ledger_rates
#
#  id          :uuid             not null, primary key
#  target_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :uuid
#  target_id   :uuid
#  tenant_id   :uuid
#  terminal_id :uuid
#
# Indexes
#
#  index_ledger_rates_on_location_id  (location_id)
#  index_ledger_rates_on_tenant_id    (tenant_id)
#  index_ledger_rates_on_terminal_id  (terminal_id)
#  ledger_rate_target_index           (target_type,target_id)
#
