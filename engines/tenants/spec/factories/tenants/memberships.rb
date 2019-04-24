# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_membership, class: 'Tenants::Membership' do
    association :group, factory: :tenants_groups
    association :member, factory: :tenants_users
    trait :user do
      association :member, factory: :tenants_users
    end
    trait :company do
      association :member, factory: :tenants_companies
    end
  end
end
