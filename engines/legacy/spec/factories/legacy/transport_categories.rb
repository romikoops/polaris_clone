# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_transport_category, class: 'Legacy::TransportCategory' do
    name { 'any' }
    mode_of_transport { 'ocean' }
    cargo_class { 'fcl_20' }
    load_type { 'container' }
    before(:create) do |transport_category|
      transport_category.update(
        vehicle: Legacy::Vehicle.where(mode_of_transport: 'ocean').first || create(:legacy_vehicle)
      )
    end

    trait :lcl do
      cargo_class { 'lcl' }
      load_type { 'cargo_item' }
    end

    trait :fcl_20 do
      cargo_class { 'fcl_20' }
      load_type { 'container' }
    end

    trait :fcl_40 do
      cargo_class { 'fcl_40' }
      load_type { 'container' }
    end

    trait :fcl_40_hq do
      cargo_class { 'fcl_40_hq' }
      load_type { 'container' }
    end

    trait :ocean do
      mode_of_transport { 'ocean' }
    end
    trait :air do
      mode_of_transport { 'air' }
    end
    trait :rail do
      mode_of_transport { 'rail' }
    end
    trait :truck do
      mode_of_transport { 'truck' }
    end

    factory :ocean_lcl, traits: %i(lcl ocean)
    factory :ocean_fcl_20, traits: %i(fcl_20 ocean)
    factory :ocean_fcl_40, traits: %i(fcl_40 ocean)
    factory :ocean_fcl_40_hq, traits: %i(fcl_40_hq ocean)
  end
end

# == Schema Information
#
# Table name: transport_categories
#
#  id                :bigint           not null, primary key
#  cargo_class       :string
#  load_type         :string
#  mode_of_transport :string
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#  vehicle_id        :integer
#
# Indexes
#
#  index_transport_categories_on_sandbox_id  (sandbox_id)
#
