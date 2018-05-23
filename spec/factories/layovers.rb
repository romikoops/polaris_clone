# frozen_string_literal: true

FactoryBot.define do
  factory :layover do
    etd Date.tomorrow + 2.days + 2.hours
    eta Date.tomorrow + 8.days
    closing_date Date.tomorrow + 5.hours
    sequence(:stop_index) { |n| n }
    association :stop
    association :trip
    association :itinerary
  end

end
