# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_deltum, class: 'Ledger::Delta' do
    association :fee, factory: :ledger_fee
    amount_cents { 2500 }
    level { 0 }
    operator { 0 }
    amount_currency { 'USD' }
    rate_basis { 0 }
    kg_range { (0..Float::INFINITY) }
    stowage_range { (0..Float::INFINITY) }
    km_range { (0..Float::INFINITY) }
    cbm_range { (0..Float::INFINITY) }
    wm_range { (0..Float::INFINITY) }
    unit_range { (0..Float::INFINITY) }
    validity { (4.days.ago..60.days.from_now) }
    min_amount_cents { 100 }
    min_amount_currency { 'USD' }
    max_amount_cents { Ledger::Delta::MAX_VALUE }
    max_amount_currency { 'USD' }
    wm_ratio { 1000 }

    trait :kg_basis do
      rate_basis { 2 }
    end

    trait :stowage_basis do
      rate_basis { 5 }
    end

    trait :wm_basis do
      rate_basis { 0 }
    end

    trait :max do
      max_cents { 100 }
    end

    trait :cbm_basis do
      rate_basis { 1 }
    end

    trait :unit_basis do
      rate_basis { 3 }
    end

    trait :shipment_basis do
      rate_basis { 6 }
    end

    trait :km_basis do
      rate_basis { 4 }
    end

    trait :percentage do
      operator { 1 }
    end

    trait :shipment_percentage do
      operator { 1 }
    end

    factory :max_delta, traits: [:max]
    factory :stowage_delta, traits: [:stowage_basis]
    factory :kg_delta, traits: [:kg_basis]
    factory :km_delta, traits: [:km_basis]
    factory :wm_delta, traits: [:wm_basis]
    factory :cbm_delta, traits: [:cbm_basis]
    factory :unit_delta, traits: [:unit_basis]
    factory :percentage_delta, traits: [:percentage]
    factory :shipment_percentage_delta, traits: [:shipment_percentage]
    factory :shipment_delta, traits: [:shipment_basis]
  end
end
