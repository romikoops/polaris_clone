# frozen_string_literal: true

FactoryBot.define do
  factory :shipment do
    association :user
    association :origin_nexus, factory: :nexus
    association :destination_nexus, factory: :nexus
    association :trip
    load_type 'container'
    before(:create) do |shipment|
      if shipment.itinerary.nil?
        shipment.itinerary_id = shipment.trip.itinerary_id
      end
    end
  end

end
