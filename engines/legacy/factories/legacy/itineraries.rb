# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_itinerary, class: "Legacy::Itinerary" do
    name { "Gothenburg - Shanghai" }
    mode_of_transport { "ocean" }
    transshipment { nil }
    association :organization, factory: :organizations_organization
    origin_hub do
      association :legacy_hub, organization: instance.organization
    end
    destination_hub do
      association :legacy_hub, organization: instance.organization
    end

    after(:build) do |itinerary|
      next if itinerary.stops.length >= 2

      index = 0
      [itinerary.origin_hub, itinerary.destination_hub].each do |hub|
        itinerary.stops << build(:legacy_stop,
          itinerary: itinerary,
          index: index,
          hub: hub)
        index += 1
      end
    end

    trait :with_trip do
      after(:create) do |itinerary|
        trip = create(:legacy_trip, itinerary: itinerary)
        itinerary.trips << trip
        trip.layovers << create(:legacy_layover,
          stop_index: 0,
          trip: trip,
          stop: itinerary.origin_stops.first,
          itinerary: itinerary)
        trip.layovers << create(:legacy_layover,
          stop_index: 1,
          trip: trip,
          stop: itinerary.destination_stops.last,
          itinerary: itinerary)
      end
    end

    trait :gothenburg_shanghai do
      name { "Gothenburg - Shanghai" }
      origin_hub do
        factory_hub_from_name(name_string: "Gothenburg", locode: "SEGOT", mot: instance.mode_of_transport, organization: instance.organization)
      end
      destination_hub do
        factory_hub_from_name(name_string: "Shanghai", locode: "CNSHA", mot: instance.mode_of_transport, organization: instance.organization)
      end
    end

    trait :shanghai_gothenburg do
      name { "Shanghai - Gothenburg" }
      origin_hub do
        factory_hub_from_name(name_string: "Shanghai", locode: "CNSHA", mot: instance.mode_of_transport, organization: instance.organization)
      end
      destination_hub do
        factory_hub_from_name(name_string: "Gothenburg", locode: "SEGOT", mot: instance.mode_of_transport, organization: instance.organization)
      end
    end

    trait :felixstowe_shanghai do
      name { "Felixstowe - Shanghai" }
      origin_hub do
        factory_hub_from_name(name_string: "Felixstowe", locode: "GBFXT", mot: instance.mode_of_transport, organization: instance.organization)
      end
      destination_hub do
        factory_hub_from_name(name_string: "Shanghai", locode: "CNSHA", mot: instance.mode_of_transport, organization: instance.organization)
      end
    end

    trait :shanghai_felixstowe do
      name { "Shanghai - Felixstowe" }
      origin_hub do
        factory_hub_from_name(name_string: "Shanghai", locode: "CNSHA", mot: instance.mode_of_transport, organization: instance.organization)
      end
      destination_hub do
        factory_hub_from_name(name_string: "Felixstowe", locode: "GBFXT", mot: instance.mode_of_transport, organization: instance.organization)
      end
    end

    trait :hamburg_shanghai do
      name { "Hamburg - Shanghai" }
      origin_hub do
        factory_hub_from_name(name_string: "Hamburg", locode: "DEHAM", mot: instance.mode_of_transport, organization: instance.organization)
      end
      destination_hub do
        factory_hub_from_name(name_string: "Shanghai", locode: "CNSHA", mot: instance.mode_of_transport, organization: instance.organization)
      end
    end

    trait :shanghai_hamburg do
      name { "Shanghai - Hamburg" }
      origin_hub do
        factory_hub_from_name(name_string: "Shanghai", locode: "CNSHA", mot: instance.mode_of_transport, organization: instance.organization)
      end
      destination_hub do
        factory_hub_from_name(name_string: "Hamburg", locode: "DEHAM", mot: instance.mode_of_transport, organization: instance.organization)
      end
    end

    factory :gothenburg_shanghai_itinerary, traits: %i[gothenburg_shanghai]
    factory :shanghai_gothenburg_itinerary, traits: %i[shanghai_gothenburg]
    factory :felixstowe_shanghai_itinerary, traits: %i[felixstowe_shanghai]
    factory :shanghai_felixstowe_itinerary, traits: %i[shanghai_felixstowe]
    factory :hamburg_shanghai_itinerary, traits: %i[hamburg_shanghai]
    factory :shanghai_hamburg_itinerary, traits: %i[shanghai_hamburg]
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
#  organization_id   :uuid
#  sandbox_id        :uuid
#  tenant_id         :integer
#
# Indexes
#
#  index_itineraries_on_mode_of_transport  (mode_of_transport)
#  index_itineraries_on_name               (name)
#  index_itineraries_on_organization_id    (organization_id)
#  index_itineraries_on_sandbox_id         (sandbox_id)
#  index_itineraries_on_tenant_id          (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
