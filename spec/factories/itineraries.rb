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
        itinerary.stops << build(:stop,
                                 itinerary: itinerary,
                                 hub: build(:hub,
                                            tenant: itinerary.tenant,
                                            nexus: build(:nexus,
                                                         tenant: itinerary.tenant)))
      end
    end
  end
end

# == Schema Information
#
# Table name: itineraries
#
#  id                :bigint(8)        not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string
#  mode_of_transport :string
#  tenant_id         :integer
#
