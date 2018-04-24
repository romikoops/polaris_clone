# frozen_string_literal: true

FactoryBot.define do
  factory :shipment do
    association :user
    association :origin, factory: :location
    association :destination, factory: :location
    load_type 'container'
  end

end
