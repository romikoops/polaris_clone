# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_trip, class: 'Legacy::Trip' do
    start_date { Date.today + 7.days }
    end_date { Date.tomorrow + 20.days }
    closing_date { Date.today + 2.days }
    association :itinerary, factory: :default_itinerary
    association :tenant_vehicle, factory: :legacy_tenant_vehicle
    trait :with_layovers do
      after(:build) do |trip|
        trip.layovers << build(:legacy_layover,
                               stop_index: 0,
                               trip: trip,
                               stop: trip.itinerary.stops.first,
                               itinerary: trip.itinerary,
                               etd: trip.start_date)
        trip.layovers << build(:legacy_layover,
                               stop_index: 1,
                               trip: trip,
                               stop: trip.itinerary.stops.last,
                               itinerary: trip.itinerary,
                               eta: trip.end_date)
      end
    end
  end
end
