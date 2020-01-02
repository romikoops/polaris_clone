# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_domain, class: 'Tenants::Domain' do
    association :tenant, factory: :tenants_tenant

    sequence(:domain) { |n| "test#{n}.example" }
    default { false }
  end
end
