# frozen_string_literal: true

FactoryBot.define do
  factory :hub do
    name 'Gothenburg Port'
    hub_type 'ocean'
    hub_status 'active'
    hub_code 'GOO1'
    association :tenant
    association :location
    association :nexus
  end
end
