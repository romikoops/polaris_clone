# frozen_string_literal: true

FactoryBot.define do
  factory :routing_location, class: 'Routing::Location' do
    locode { }
    name { 'Hamburg' }
    country_code { 'de' }
    bounds { FactoryBot.build(:legacy_bounds, lat: 53.558572, lng: 9.9278215, delta: 0.4) }
    center { FactoryBot.build(:point, lat: 53.558572, lng: 9.9278215) }

    transient do
      all_mots { false }
    end

    after(:build) do |location, evaluator|
      if evaluator.all_mots
        (1..4).each do |mot|
          location.terminals << FactoryBot.build(:routing_terminal, center: location.center, location: location, mode_of_transport: mot)
        end
      end
      existing_locode = Routing::Location.find_by(locode: location.locode)
      existing_locode
    end

    trait :hamburg do
      locode { 'DEHAM' }
      name { 'Hamburg' }
      country_code { 'de' }
      bounds { FactoryBot.build(:legacy_bounds, lat: 53.558572, lng: 9.9278215, delta: 0.4) }
      center { FactoryBot.build(:point, lat: 53.558572, lng: 9.9278215) }
    end

    trait :shanghai do
      locode { 'CNSHA' }
      name { 'Shanghai' }
      country_code { 'cn' }
      bounds { FactoryBot.build(:legacy_bounds, lat: 31.2231338, lng: 120.9162975, delta: 0.4) }
      center { FactoryBot.build(:point, lat: 31.2231338, lng: 120.9162975) }
    end

    trait :felixstowe do
      locode { 'GBFXT' }
      name { 'Felixstowe' }
      country_code { 'gb' }
      bounds { FactoryBot.build(:legacy_bounds, lat: 51.966, lng: 1.3277, delta: 0.4) }
      center { FactoryBot.build(:point, lat: 51.966, lng: 1.3277) }
    end

    trait :gothenburg do
      locode { 'SEGOT' }
      name { 'Gothenburg' }
      country_code { 'se' }
      bounds { FactoryBot.build(:legacy_bounds, lat: 57.694253, lng: 11.854048, delta: 0.4) }
      center { FactoryBot.build(:point, lat: 57.694253, lng: 11.854048) }
    end

    trait :rotterdam do
      locode { 'NLRTM' }
      name { 'Rotterdam' }
      country_code { 'nl' }
      bounds { FactoryBot.build(:legacy_bounds, lat: 51.9280573, lng: 4.4203672, delta: 0.4) }
      center { FactoryBot.build(:point, lat: 51.9280573, lng: 4.4203672) }
    end

    trait :ningbo do
      locode { 'CNNBO' }
      name { 'Ningbo' }
      country_code { 'cn' }
      bounds { FactoryBot.build(:legacy_bounds, lat: 29.8700041, lng: 121.4318779, delta: 0.4) }
      center { FactoryBot.build(:point, lat: 29.8700041, lng: 121.4318779) }
    end

    trait :veracruz do
      locode { 'MXVER' }
      name { 'Veracruz' }
      country_code { 'mx' }
      bounds { FactoryBot.build(:legacy_bounds, lat: 19.1787535, lng: -96.2463566, delta: 0.4) }
      center { FactoryBot.build(:point, lat: 19.1787535, lng: -96.2463566) }
    end

    factory :felixstowe_location, traits: [:felixstowe]
    factory :shanghai_location, traits: [:shanghai]
    factory :gothenburg_location, traits: [:gothenburg]
    factory :rotterdam_location, traits: [:rotterdam]
    factory :ningbo_location, traits: [:ningbo]
    factory :veracruz_location, traits: [:veracruz]
    factory :hamburg_location, traits: [:hamburg]
  end
end

# == Schema Information
#
# Table name: routing_locations
#
#  id           :uuid             not null, primary key
#  bounds       :geometry         geometry, 0
#  center       :geometry         geometry, 0
#  country_code :string
#  locode       :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_routing_locations_on_bounds  (bounds) USING gist
#  index_routing_locations_on_center  (center)
#  index_routing_locations_on_locode  (locode)
#
