# frozen_string_literal: true

FactoryBot.define do
  factory :nexus do
    name 'Gothenburg'
    latitude '57.694253'
    longitude '11.854048'
    association :tenant
    association :country
  end
end
