# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :legacy_charge_categories, class: 'Legacy::ChargeCategory' do # rubocop:disable Metrics/BlockLength
    name { 'Grand Total' }
    code { 'grand_total' }

    trait :bas do
      name { 'Basic Ocean Freight' }
      code { 'bas' }
    end

    trait :solas do
      name { 'SOLAS FEE' }
      code { 'solas' }
    end

    trait :baf do
      name { 'Bunker Adjustment Fee' }
      code { 'baf' }
    end

    trait :has do
      name { 'Heavy Weight Freight' }
      code { 'has' }
    end

    trait :puf do
      name { 'Pick Up Fee' }
      code { 'puf' }
    end

    trait :trucking_pre do
      name { 'Trucking' }
      code { 'trucking_pre' }
    end

    trait :trucking_on do
      name { 'Trucking' }
      code { 'trucking_on' }
    end


    factory :bas_charge, traits: [:bas]
    factory :solas_charge, traits: [:solas]
    factory :baf_charge, traits: [:baf]
    factory :has_charge, traits: [:has]
    factory :puf_charge, traits: [:puf]
    factory :trucking_pre_charge, traits: [:trucking_pre]
    factory :trucking_on_charge, traits: [:trucking_on]
  end
end
