# frozen_string_literal: true

FactoryBot.define do
  factory :trip do
    start_date Date.today
    end_date Date.tomorrow
    association :itinerary
    association :tenant_vehicle
  end
end
