# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_max_dimensions_bundle, class: 'Legacy::MaxDimensionsBundle' do
    association :tenant, factory: :legacy_tenant

    mode_of_transport { 'general' }
    cargo_class { 'lcl' }
    aggregate { false }
    dimension_x { 500 }
    dimension_y { 500 }
    dimension_z { 500 }
    payload_in_kg { 10_000 }
    chargeable_weight { 10_000 }

    trait :aggregated do
      mode_of_transport { 'general' }
      aggregate { true }
      dimension_x { 5000 }
      dimension_y { 5000 }
      dimension_z { 5000 }
      payload_in_kg { 21770 }
      chargeable_weight { 21770 }
    end

    factory :aggregated_max_dimensions_bundle, traits: [:aggregated]
  end
end

# == Schema Information
#
# Table name: max_dimensions_bundles
#
#  id                :bigint           not null, primary key
#  aggregate         :boolean
#  cargo_class       :string
#  chargeable_weight :decimal(, )
#  dimension_x       :decimal(, )
#  dimension_y       :decimal(, )
#  dimension_z       :decimal(, )
#  mode_of_transport :string
#  payload_in_kg     :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  carrier_id        :bigint
#  itinerary_id      :bigint
#  sandbox_id        :uuid
#  tenant_id         :integer
#  tenant_vehicle_id :bigint
#
# Indexes
#
#  index_max_dimensions_bundles_on_cargo_class        (cargo_class)
#  index_max_dimensions_bundles_on_carrier_id         (carrier_id)
#  index_max_dimensions_bundles_on_itinerary_id       (itinerary_id)
#  index_max_dimensions_bundles_on_mode_of_transport  (mode_of_transport)
#  index_max_dimensions_bundles_on_sandbox_id         (sandbox_id)
#  index_max_dimensions_bundles_on_tenant_id          (tenant_id)
#  index_max_dimensions_bundles_on_tenant_vehicle_id  (tenant_vehicle_id)
#
