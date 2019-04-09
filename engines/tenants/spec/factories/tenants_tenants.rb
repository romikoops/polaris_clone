# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_tenant, class: 'Tenants::Tenant' do
    subdomain { 'test' }
  end
end
