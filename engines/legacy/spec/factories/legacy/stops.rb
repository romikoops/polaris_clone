# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_stop, class: 'Legacy::Stop' do
    association :hub, factory: :legacy_hub
    association :itinerary, factory: :default_itinerary
    sequence(:index) { |n| n }
  end
end
