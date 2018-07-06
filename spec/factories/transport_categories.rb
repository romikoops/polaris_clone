# frozen_string_literal: true

FactoryBot.define do
  factory :transport_category do
    name 'any'
    mode_of_transport 'ocean'
    cargo_class 'fcl_20'
    load_type 'container'
    before(:create) do |transport_category|
      transport_category.update(
        vehicle: Vehicle.where(mode_of_transport: "ocean").first || create(:vehicle)
      )
    end
  end

end
