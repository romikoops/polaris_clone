# frozen_string_literal: true

FactoryBot.define do
  factory :transport_category do
    name 'any'
    mode_of_transport 'ocean'
    cargo_class 'fcl_20'
    load_type 'container'

    association :vehicle
  end

end
