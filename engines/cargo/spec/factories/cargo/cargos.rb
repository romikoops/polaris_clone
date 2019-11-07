# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_cargo, class: 'Cargo::Cargo' do
    association :tenant, factory: :tenants_tenant
  end
end
