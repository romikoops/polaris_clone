# frozen_string_literal: true

FactoryBot.define do
  factory :pricings_detail, class: 'Pricings::Detail' do
    value { 0.10 }
    operator { '%' }
    association :charge_category, factory: :legacy_charge_categories
    association :tenant, factory: :tenants_tenant
    association :margin, factory: :pricings_margin
    trait :bas_detail do
      association :charge_category, factory: :bas_charge
    end

    trait :bas_addition_detail do
      association :charge_category, factory: :bas_charge
      operator { '+' }
      value { 30 }
    end

    factory :bas_margin_detail, traits: [:bas_detail]
    factory :bas_addition_margin_detail, traits: [:bas_addition_detail]
  end
end
