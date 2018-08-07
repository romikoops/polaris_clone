# frozen_string_literal: true

FactoryBot.define do
  factory :itinerary do
    transient do
      num_stops 2
    end

    name 'Gothenburg - Shanghai'
    mode_of_transport 'ocean'
    association :tenant

    after(:build) do |itinerary|
      # awesome_print itinerary.tenant.scope.deep_symbolize_keys
      2.times do
        itinerary.stops << create(:stop, itinerary: itinerary,
        hub: create(:hub, tenant: itinerary.tenant, nexus: create(:nexus, tenant: itinerary.tenant)))
      end
    end
  end
end
