# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :legacy_itinerary, class: 'Legacy::Itinerary' do # rubocop:disable Metrics/BlockLength
    transient do
      num_stops { 2 }
    end

    name { 'Gothenburg - Shanghai' }
    mode_of_transport { 'ocean' }
    association :tenant, factory: :legacy_tenant

    trait :default do
      after(:build) do |itinerary, evaluator|
        next if itinerary.stops.length >= 2

        index = 0
        evaluator.num_stops.times do
          itinerary.stops << build(:legacy_stop,
                                  itinerary: itinerary,
                                  index: index,
                                  hub: build(:legacy_hub,
                                              tenant: itinerary.tenant,
                                              hub_type: itinerary.mode_of_transport,
                                              nexus: build(:legacy_nexus,
                                                          tenant: itinerary.tenant)))
          index += 1
        end
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

    trait :gothenburg_shanghai do
      name { 'Gothenburg - Shanghai' }

      after(:build) do |itinerary|
        next if itinerary.stops.length >= 2
        hub = Legacy::Hub.find_by(name: 'Shanghai Port')

        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: build(:gothenburg_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:gothenburg_nexus,
                                                         tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: (hub || build(:shanghai_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:shanghai_nexus,
                                                         tenant: itinerary.tenant))))
      end
    end

    trait :shanghai_gothenburg do
      name { 'Shanghai - Gothenburg' }
      after(:build) do |itinerary|
        next if itinerary.stops.length >= 2

        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: build(:shanghai_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:shanghai_nexus,
                                                         tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: build(:gothenburg_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:gothenburg_nexus,
                                                         tenant: itinerary.tenant)))
      end
    end

    trait :felixstowe_shanghai do
      name { 'Felixstowe - Shanghai' }
      after(:build) do |itinerary|
        next if itinerary.stops.length >= 2
        hub = Legacy::Hub.find_by(name: 'Shanghai Port')

        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: build(:felixstowe_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:felixstowe_nexus,
                                                         tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: (hub || build(:shanghai_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:shanghai_nexus,
                                                         tenant: itinerary.tenant))))
      end
    end

    trait :shanghai_felixstowe do
      name { 'Shanghai - Felixstowe' }
      after(:build) do |itinerary|
        next if itinerary.stops.length >= 2

        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: build(:shanghai_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:shanghai_nexus,
                                                         tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: build(:felixstowe_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:felixstowe_nexus,
                                                         tenant: itinerary.tenant)))
      end
    end

    trait :hamburg_shanghai do
      name { 'Hamburg - Shanghai' }
      after(:build) do |itinerary|
        next if itinerary.stops.length >= 2
        hub = Legacy::Hub.find_by(name: 'Shanghai Port')

        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: build(:hamburg_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:hamburg_nexus,
                                                         tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: (hub || build(:shanghai_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:shanghai_nexus,
                                                         tenant: itinerary.tenant))))
      end
    end

    trait :shanghai_hamburg do
      name { 'Shanghai - Hamburg' }
      after(:build) do |itinerary|
        next if itinerary.stops.length >= 2

        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: build(:shanghai_hub,
                                            hub_type: itinerary.mode_of_transport,
                                            tenant: itinerary.tenant,
                                            nexus: build(:shanghai_nexus,
                                                         tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: build(:hamburg_hub,
                                            tenant: itinerary.tenant,
                                            hub_type: itinerary.mode_of_transport,
                                            nexus: build(:hamburg_nexus,
                                                         tenant: itinerary.tenant)))
      end
    end

    factory :gothenburg_shanghai_itinerary, traits: [:gothenburg_shanghai]
    factory :shanghai_gothenburg_itinerary, traits: [:shanghai_gothenburg]
    factory :felixstowe_shanghai_itinerary, traits: [:felixstowe_shanghai]
    factory :shanghai_felixstowe_itinerary, traits: [:shanghai_felixstowe]
    factory :hamburg_shanghai_itinerary, traits: [:hamburg_shanghai]
    factory :shanghai_hamburg_itinerary, traits: [:shanghai_hamburg]
    factory :default_itinerary, traits: [:default]
  end
end

# == Schema Information
#
# Table name: itineraries
#
#  id                :bigint           not null, primary key
#  mode_of_transport :string
#  name              :string
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
