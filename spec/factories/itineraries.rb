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
    association :origin_hub, factory: :hub
    association :destination_hub, factory: :hub

    after(:build) do |itinerary, evaluator|
      next if itinerary.stops.length >= 2

      evaluator.num_stops.times do |i|
        stop = build(:stop,
                                 itinerary: itinerary,
                                 index: i,
                                 hub: build(:hub,
                                            tenant: itinerary.tenant,
                                            nexus: build(:nexus,
                                                         tenant: itinerary.tenant)))
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

# == Schema Information
#
# Table name: itineraries
#
#  id                 :bigint           not null, primary key
#  mode_of_transport  :string
#  name               :string
#  transshipment      :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  destination_hub_id :bigint
#  origin_hub_id      :bigint
#  sandbox_id         :uuid
#  tenant_id          :integer
#
# Indexes
#
#  index_itineraries_on_destination_hub_id  (destination_hub_id)
#  index_itineraries_on_mode_of_transport   (mode_of_transport)
#  index_itineraries_on_name                (name)
#  index_itineraries_on_origin_hub_id       (origin_hub_id)
#  index_itineraries_on_sandbox_id          (sandbox_id)
#  index_itineraries_on_tenant_id           (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (destination_hub_id => hubs.id)
#  fk_rails_...  (origin_hub_id => hubs.id)
#
