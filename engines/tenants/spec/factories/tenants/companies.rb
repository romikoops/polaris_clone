# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_company, class: 'Tenants::Company' do
    name { 'ItsMyCargo GmbH' }
    sequence(:email) { |n| "admin#{n}@itsmycargo.test" }
    vat_number { '123456789' }
    association :tenant, factory: :tenants_tenant
  end
end
