# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_trip, class: 'Legacy::Trip' do
    start_date { Time.zone.today + 7.days }
    end_date { Time.zone.tomorrow + 20.days }
    closing_date { Time.zone.today + 2.days }
    association :itinerary, factory: :default_itinerary
    load_type { 'cargo_item' }
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

    factory :trip_with_layovers, traits: [:with_layovers]
  end
end

# == Schema Information
#
# Table name: trips
#
#  id                :bigint           not null, primary key
#  closing_date      :datetime
#  end_date          :datetime
#  load_type         :string
#  start_date        :datetime
#  vessel            :string
#  voyage_code       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  itinerary_id      :integer
#  sandbox_id        :uuid
#  tenant_vehicle_id :integer
#
# Indexes
#
#  index_trips_on_closing_date       (closing_date)
#  index_trips_on_itinerary_id       (itinerary_id)
#  index_trips_on_sandbox_id         (sandbox_id)
#  index_trips_on_tenant_vehicle_id  (tenant_vehicle_id)
#
