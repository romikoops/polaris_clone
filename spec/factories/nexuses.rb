# frozen_string_literal: true

FactoryBot.define do
  factory :nexus, class: 'Location' do
    name 'Gothenburg'
    location_type 'nexus'
    latitude '57.694253'
    longitude '11.854048'
    geocoded_address 'Port 4, Indiska Oceanen 11, 418 34 Göteborg, Sverige'
    city 'Gothenburg'
    association :country
  end
end
