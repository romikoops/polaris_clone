# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_tenant, class: 'Legacy::Tenant' do
    subdomain { 'test' }
  end
end
