# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_nexus, class: 'Legacy::Nexus' do
    name { 'Gothenburg' }
    latitude { '57.694253' }
    longitude { '11.854048' }
    association :tenant, factory: :legacy_tenant
    association :country, factory: :legacy_country
  end
end
