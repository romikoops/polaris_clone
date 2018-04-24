# frozen_string_literal: true

FactoryBot.define do
  factory :stop do
    association :hub
    association :itinerary
    sequence(:index) { |n| n }
  end
end
