# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :legacy_itinerary, class: 'Legacy::Itinerary' do # rubocop:disable Metrics/BlockLength
    transient do
      num_stops { 2 }
    end

    name { 'Gothenburg - Shanghai' }
    mode_of_transport { 'ocean' }
    association :tenant, factory: :legacy_tenant

    after(:build) do |itinerary, evaluator|
      next if itinerary.stops.length >= 2

      index = 0
      evaluator.num_stops.times do
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: index,
                                 hub: build(:legacy_hub,
                                            tenant: itinerary.tenant,
                                            nexus: build(:legacy_nexus,
                                                         tenant: itinerary.tenant)))
        index += 1
      end
    end

    trait :with_trip do
      after(:build) do |itinerary|
        trip = build(:legacy_trip, itinerary: itinerary)
        itinerary.trips << trip
        trip.layovers << build(:legacy_layover,
                               stop_index: 0,
                               trip: trip,
                               stop: itinerary.stops.first,
                               itinerary: itinerary)
        trip.layovers << build(:legacy_layover,
                               stop_index: 1,
                               trip: trip,
                               stop: itinerary.stops.last,
                               itinerary: itinerary)
      end
    end
  end
end
