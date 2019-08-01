# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_layover, class: 'Legacy::Layover' do
    etd { Date.tomorrow + 7.days + 2.hours }
    eta { Date.tomorrow + 11.days }
    closing_date { Date.tomorrow + 4.days + 5.hours }
    sequence(:stop_index) { |n| n }
    association :stop, factory: :legacy_stop
    association :trip, factory: :legacy_trip
    association :itinerary, factory: :default_itinerary
  end
end
