# frozen_string_literal: true

FactoryBot.define do
  factory :itinerary do
    transient do
      num_stops { 2 }
    end

    name { "Gothenburg - Shanghai" }
    mode_of_transport { "ocean" }
    transshipment { nil }
    association :organization, factory: :organizations_organization
    association :origin_hub, factory: :hub
    association :destination_hub, factory: :hub

    trait :with_trip do
      after(:build) do |itinerary|
        trip = build(:trip, itinerary: itinerary)
        itinerary.trips << trip
      end
    end
  end
end
