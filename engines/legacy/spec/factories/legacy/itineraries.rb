# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :legacy_itinerary, class: 'Legacy::Itinerary' do # rubocop:disable Metrics/BlockLength
    transient do
      num_stops { 2 }
    end

    name { 'Gothenburg - Shanghai' }
    mode_of_transport { 'ocean' }
    transshipment { nil }
    association :tenant, factory: :legacy_tenant
    association :origin_hub, factory: :legacy_hub
    association :destination_hub, factory: :legacy_hub

    trait :with_hubs do
      after(:build) do |itinerary, evaluator|
        if itinerary.stops.length >= 2
          itinerary.origin_hub = itinerary.stops.find { |stop| stop.index == 0 }.hub
          itinerary.destination_hub = itinerary.stops.find { |stop| stop.index == 1 }.hub
        end
      end
    end

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

        shanghai = Legacy::Hub.find_by(hub_code: 'CNSHA', tenant: itinerary.tenant)
        gothenburg = Legacy::Hub.find_by(hub_code: 'SEGOT', tenant: itinerary.tenant)

        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: gothenburg || build(:gothenburg_hub,
                                                          tenant: itinerary.tenant,
                                                          hub_type: itinerary.mode_of_transport,
                                                          nexus: build(:gothenburg_nexus,
                                                                       tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: (shanghai || build(:shanghai_hub,
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

        shanghai = Legacy::Hub.find_by(name: 'Shanghai Port', tenant: itinerary.tenant)
        gothenburg = Legacy::Hub.find_by(name: 'Gothenburg Port', tenant: itinerary.tenant)
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: shanghai || build(:shanghai_hub,
                                                        tenant: itinerary.tenant,
                                                        hub_type: itinerary.mode_of_transport,
                                                        nexus: build(:shanghai_nexus,
                                                                     tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: gothenburg || build(:gothenburg_hub,
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

        shanghai = Legacy::Hub.find_by(name: 'Shanghai Port', tenant: itinerary.tenant)
        felixstowe = Legacy::Hub.find_by(name: 'Felixstowe Port', tenant: itinerary.tenant)
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: felixstowe || build(:felixstowe_hub,
                                                          tenant: itinerary.tenant,
                                                          hub_type: itinerary.mode_of_transport,
                                                          nexus: build(:felixstowe_nexus,
                                                                       tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: (shanghai || build(:shanghai_hub,
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

        shanghai = Legacy::Hub.find_by(name: 'Shanghai Port', tenant: itinerary.tenant)
        felixstowe = Legacy::Hub.find_by(name: 'Felixstowe Port', tenant: itinerary.tenant)
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: shanghai || build(:shanghai_hub,
                                                        tenant: itinerary.tenant,
                                                        hub_type: itinerary.mode_of_transport,
                                                        nexus: build(:shanghai_nexus,
                                                                     tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: felixstowe || build(:felixstowe_hub,
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

        shanghai = Legacy::Hub.find_by(name: 'Shanghai Port', tenant: itinerary.tenant)
        hamburg = Legacy::Hub.find_by(name: 'Hamburg Port', tenant: itinerary.tenant)
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: hamburg || build(:hamburg_hub,
                                                       tenant: itinerary.tenant,
                                                       hub_type: itinerary.mode_of_transport,
                                                       nexus: build(:hamburg_nexus,
                                                                    tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: (shanghai || build(:shanghai_hub,
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

        shanghai = Legacy::Hub.find_by(name: 'Shanghai Port', tenant: itinerary.tenant)
        hamburg = Legacy::Hub.find_by(name: 'Hamburg Port', tenant: itinerary.tenant)
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 0,
                                 hub: shanghai || build(:shanghai_hub,
                                                        hub_type: itinerary.mode_of_transport,
                                                        tenant: itinerary.tenant,
                                                        nexus: build(:shanghai_nexus,
                                                                     tenant: itinerary.tenant)))
        itinerary.stops << build(:legacy_stop,
                                 itinerary: itinerary,
                                 index: 1,
                                 hub: hamburg || build(:hamburg_hub,
                                                       tenant: itinerary.tenant,
                                                       hub_type: itinerary.mode_of_transport,
                                                       nexus: build(:hamburg_nexus,
                                                                    tenant: itinerary.tenant)))
      end
    end

    factory :gothenburg_shanghai_itinerary, traits: [:gothenburg_shanghai, :with_hubs]
    factory :shanghai_gothenburg_itinerary, traits: [:shanghai_gothenburg, :with_hubs]
    factory :felixstowe_shanghai_itinerary, traits: [:felixstowe_shanghai, :with_hubs]
    factory :shanghai_felixstowe_itinerary, traits: [:shanghai_felixstowe, :with_hubs]
    factory :hamburg_shanghai_itinerary, traits: [:hamburg_shanghai, :with_hubs]
    factory :shanghai_hamburg_itinerary, traits: [:shanghai_hamburg, :with_hubs]
    factory :default_itinerary, traits: [:default, :with_hubs]
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
