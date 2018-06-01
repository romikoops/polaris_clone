# frozen_string_literal: true

FactoryBot.define do
  factory :shipment do
    association :user
    association :origin_nexus, factory: :location
    association :destination_nexus, factory: :location
    load_type 'container'
  end

end
