# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :legacy_charge_categories, class: 'Legacy::ChargeCategory' do # rubocop:disable Metrics/BlockLength
    name { 'Grand Total' }
    code { 'grand_total' }

    trait :bas do
      name { 'Basic Ocean Freight' }
      code { 'BAS' }
    end

    trait :solas do
      name { 'SOLAS FEE' }
      code { 'SOLAS' }
    end

    trait :baf do
      name { 'Bunker Adjustment Fee' }
      code { 'BAF' }
    end

    trait :has do
      name { 'Heavy Weight Freight' }
      code { 'HAS' }
    end

    trait :puf do
      name { 'Pick Up Fee' }
      code { 'PUF' }
    end

    factory :bas_charge, traits: [:bas]
    factory :solas_charge, traits: [:solas]
    factory :baf_charge, traits: [:baf]
    factory :has_charge, traits: [:has]
    factory :puf_charge, traits: [:puf]
  end
end
