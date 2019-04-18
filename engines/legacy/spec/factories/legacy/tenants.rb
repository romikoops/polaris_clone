# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_tenant, class: 'Legacy::Tenant' do
    sequence(:name) { |n| "Test #{n}" }
    sequence(:subdomain) { |n| "test#{n}" }
  end
end
