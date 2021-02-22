# frozen_string_literal: true
FactoryBot.define do
  factory :routing_point, class: "RGeo::Geos::CAPIPointImpl" do
    lat { 53.558572 }
    lng { 9.9278215 }
    initialize_with do
      RGeo::Cartesian.factory.point(lng, lat)
    end
  end
end
