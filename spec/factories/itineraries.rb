# frozen_string_literal: true

FactoryBot.define do
  factory :itinerary do
    transient do
      num_stops { 2 }
    end

    name { 'Gothenburg - Shanghai' }
    mode_of_transport { 'ocean' }
    transshipment { nil }
    association :tenant

    after(:build) do |itinerary, evaluator|
      next if itinerary.stops.length >= 2

      evaluator.num_stops.times do |i|
        itinerary.stops << build(:stop,
                                 itinerary: itinerary,
                                 index: i,
                                 hub: build(:hub,
                                            tenant: itinerary.tenant,
                                            nexus: build(:nexus,
                                                         tenant: itinerary.tenant)))
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
#  mode_of_transport :string
#  name              :string
#  transshipment     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#  tenant_id         :integer
#
# Indexes
#
#  index_itineraries_on_mode_of_transport  (mode_of_transport)
#  index_itineraries_on_name               (name)
#  index_itineraries_on_sandbox_id         (sandbox_id)
#  index_itineraries_on_tenant_id          (tenant_id)
#
