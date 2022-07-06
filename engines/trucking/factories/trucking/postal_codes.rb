# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_postal_code, class: "Trucking::PostalCode" do
    association :country, factory: :legacy_country
    sequence(:postal_code) { |n| 10_000 + n }
    point { RGeo::Geos.factory(srid: 4326).point(12.34, 53.2) }
  end
end
