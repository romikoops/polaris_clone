# frozen_string_literal: true

FactoryBot.define do
  factory :itinerary do
    transient do
      num_stops { 2 }
    end

    name { 'Gothenburg - Shanghai' }
    mode_of_transport { 'ocean' }
    transshipment { nil }
    association :organization, factory: :organizations_organization
    association :origin_hub, factory: :hub
    association :destination_hub, factory: :hub

    after(:build) do |itinerary, evaluator|
      next if itinerary.stops.length >= 2

      evaluator.num_stops.times do |i|
        stop = build(:stop,
                                 itinerary: itinerary,
                                 index: i,
                                 hub: build(:hub,
                                            organization: itinerary.organization,
                                            nexus: build(:nexus,
                                                         organization: itinerary.organization)))
        itinerary.stops << stop
        if i == 1
          itinerary.origin_hub = stop.hub
        else
          itinerary.destination_hub = stop.hub
        end
      end
    end

    trait :with_trip do
      after(:build) do |itinerary|
        trip = build(:trip, itinerary: itinerary)
        itinerary.trips << trip
        trip.layovers << build(:layover, stop_index: 0, trip: trip, stop: itinerary.stops.first, itinerary: itinerary)
        trip.layovers << build(:layover, stop_index: 1, trip: trip, stop: itinerary.stops.last, itinerary: itinerary)
      end
    end
  end
end
