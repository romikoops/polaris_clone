# frozen_string_literal: true

FactoryBot.define do
  factory :layover do
    etd Date.today
    eta Date.today
    closing_date Date.tomorrow
    sequence(:stop_index) { |n| n }
    association :stop
    association :trip
    association :itinerary
  end

end
