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
      2.times { itinerary.stops << create(:stop, itinerary: itinerary) }
    end
  end

end
