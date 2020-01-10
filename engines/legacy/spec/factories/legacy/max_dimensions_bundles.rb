# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_max_dimensions_bundle, class: 'Legacy::MaxDimensionsBundle' do
    association :tenant, factory: :legacy_tenant
    mode_of_transport { 'general' }
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
#  mode_of_transport :string
#  tenant_id         :integer
#  aggregate         :boolean
#  dimension_x       :decimal(, )
#  dimension_y       :decimal(, )
#  dimension_z       :decimal(, )
#  payload_in_kg     :decimal(, )
#  chargeable_weight :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#
