# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_max_dimensions_bundle, class: 'Legacy::MaxDimensionsBundle' do
    association :organization, factory: :organizations_organization
    mode_of_transport { 'general' }
    cargo_class { 'lcl' }
    aggregate { false }
    width { 500 }
    length { 500 }
    height { 500 }
    payload_in_kg { 10_000 }
    chargeable_weight { 10_000 }
    volume { 10_000 }

    trait :aggregated do
      mode_of_transport { 'general' }
      aggregate { true }
      width { 5000 }
      length { 5000 }
      height { 5000 }
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
#  organization_id   :uuid
#  itinerary_id      :bigint
#  sandbox_id        :uuid
#  tenant_id         :integer
#  tenant_vehicle_id :bigint
#
# Indexes
#
#  index_max_dimensions_bundles_on_cargo_class        (cargo_class)
#  index_max_dimensions_bundles_on_carrier_id         (carrier_id)
#  index_max_dimensions_bundles_on_mode_of_transport  (mode_of_transport)
#  index_max_dimensions_bundles_on_organization_id    (organization_id)
#  index_max_dimensions_bundles_on_sandbox_id         (sandbox_id)
#  index_max_dimensions_bundles_on_tenant_id          (tenant_id)
#  index_max_dimensions_bundles_on_tenant_vehicle_id  (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
