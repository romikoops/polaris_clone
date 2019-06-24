# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :pricings_margin, class: 'Pricings::Margin' do # rubocop:disable Metrics/BlockLength
    value { 0.10 }
    operator { '%' }
    margin_type { :freight_margin }
    effective_date { Date.today.beginning_of_day }
    expiration_date { 6.months.from_now.end_of_day }
    association :tenant, factory: :tenants_tenant
    association :applicable, factory: :legacy_user

    trait :freight do
      margin_type { :freight_margin }
    end

    trait :export do
      margin_type { :export_margin }
    end

    trait :import do
      margin_type { :import_margin }
    end

    trait :trucking_pre do
      margin_type { :trucking_pre_margin }
    end

    trait :trucking_on do
      margin_type { :trucking_on_margin }
    end

    trait :user do
      association :applicable, factory: :legacy_user
    end

    trait :group do
      association :applicable, factory: :users_group
    end

    trait :addition do
      value { 10 }
      operator { '+' }
    end

    trait :tenant do
      association :applicable, factory: :legacy_tenant
    end

    factory :user_margin, traits: [:user]
    factory :group_margin, traits: [:group]
    factory :tenant_margin, traits: [:tenant]
    factory :addition_margin, traits: [:addition]
    factory :freight_margin, traits: [:freight]
    factory :import_margin, traits: [:import]
    factory :export_margin, traits: [:export]
    factory :trucking_pre_margin, traits: [:trucking_pre]
    factory :trucking_on_margin, traits: [:trucking_on]
  end
end
