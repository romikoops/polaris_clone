# frozen_string_literal: true

FactoryBot.define do
  factory :itinerary do
    transient do
      num_stops { 2 }
    end

    name { 'Gothenburg - Shanghai' }
    mode_of_transport { 'ocean' }
    association :tenant

    after(:build) do |itinerary, evaluator|
      next if itinerary.stops.length >= 2

      evaluator.num_stops.times do
        index = 0
        itinerary.stops << build(:stop,
                                 itinerary: itinerary,
                                 index: index,
                                 hub: build(:hub,
                                            tenant: itinerary.tenant,
                                            nexus: build(:nexus,
                                                         tenant: itinerary.tenant)))
        index += 1
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

# == Schema Information
#
# Table name: itineraries
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string
#  mode_of_transport :string
#  tenant_id         :integer
#  sandbox_id        :uuid
#
