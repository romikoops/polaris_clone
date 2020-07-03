# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :pricings_rate_basis, class: 'Pricings::RateBasis' do # rubocop:disable Metrics/BlockLength
    internal_code { 'PER_CONTAINER' }
    external_code { 'PER_CONTAINER' }

    trait :container do
      internal_code { 'PER_CONTAINER' }
      external_code { 'PER_CONTAINER' }
    end

    trait :wm do
      internal_code { 'PER_WM' }
      external_code { 'PER_WM' }
    end

    trait :hbl do
      internal_code { 'PER_SHIPMENT' }
      external_code { 'PER_HBL' }
    end

    trait :shipment do
      internal_code { 'PER_SHIPMENT' }
      external_code { 'PER_SHIPMENT' }
    end

    trait :item do
      internal_code { 'PER_ITEM' }
      external_code { 'PER_ITEM' }
    end

    trait :cbm do
      internal_code { 'PER_CBM' }
      external_code { 'PER_CBM' }
    end

    trait :kg do
      internal_code { 'PER_KG' }
      external_code { 'PER_KG' }
    end

    trait :kg_per_cbm do
      internal_code { 'CBM_PER_KG' }
      external_code { 'CBM_PER_KG' }
    end

    trait :x_kg_flat do
      internal_code { 'PER_X_KG_FLAT' }
      external_code { 'PER_X_KG_FLAT' }
    end

    trait :cbm_ton do
      internal_code { 'PER_CBM_TON' }
      external_code { 'PER_CBM_TON' }
    end

    trait :ton do
      internal_code { 'PER_TON' }
      external_code { 'PER_TON' }
    end

    trait :kg_range do
      internal_code { 'PER_KG_RANGE' }
      external_code { 'PER_KG_RANGE' }
    end

    trait :kg_range_flat do
      internal_code { 'PER_KG_RANGE_FLAT' }
      external_code { 'PER_KG_RANGE_FLAT' }
    end

    trait :unit_ton_cbm_range do
      internal_code { 'PER_UNIT_TON_CBM_RANGE' }
      external_code { 'PER_UNIT_TON_CBM_RANGE' }
    end

    trait :container_range do
      internal_code { 'PER_CONTAINER_RANGE' }
      external_code { 'PER_CONTAINER_RANGE' }
    end

    trait :unit_range do
      internal_code { 'PER_UNIT_RANGE' }
      external_code { 'PER_UNIT_RANGE' }
    end

    trait :cbm_range do
      internal_code { 'PER_CBM_RANGE' }
      external_code { 'PER_CBM_RANGE' }
    end

    trait :wm_range do
      internal_code { 'PER_WM_RANGE' }
      external_code { 'PER_WM_RANGE' }
    end

    trait :container_range_flat do
      internal_code { 'PER_CONTAINER_RANGE_FLAT' }
      external_code { 'PER_CONTAINER_RANGE_FLAT' }
    end

    trait :unit_range_flat do
      internal_code { 'PER_UNIT_RANGE_FLAT' }
      external_code { 'PER_UNIT_RANGE_FLAT' }
    end

    trait :cbm_range_flat do
      internal_code { 'PER_CBM_RANGE_FLAT' }
      external_code { 'PER_CBM_RANGE_FLAT' }
    end

    trait :wm_range_flat do
      internal_code { 'PER_WM_RANGE_FLAT' }
      external_code { 'PER_WM_RANGE_FLAT' }
    end

    factory :per_wm_rate_basis, traits: [:wm]
    factory :per_container_rate_basis, traits: [:container]
    factory :per_hbl_rate_basis, traits: [:hbl]
    factory :per_shipment_rate_basis, traits: [:shipment]
    factory :per_item_rate_basis, traits: [:item]
    factory :per_cbm_rate_basis, traits: [:cbm]
    factory :per_kg_rate_basis, traits: [:kg]
    factory :per_kg_per_cbm_rate_basis, traits: [:kg_per_cbm]
    factory :per_x_kg_flat_rate_basis, traits: [:x_kg_flat]
    factory :per_cbm_ton_rate_basis, traits: [:cbm_ton]
    factory :per_ton_rate_basis, traits: [:ton]
    factory :per_kg_range_rate_basis, traits: [:kg_range]
    factory :per_kg_range_bases_rate_basis, traits: [:kg_range]
    factory :per_kg_range_flat_rate_basis, traits: [:kg_range_flat]
    factory :per_unit_ton_cbm_range_rate_basis, traits: [:unit_ton_cbm_range]
    factory :per_container_range_rate_basis, traits: [:container_range]
    factory :per_unit_range_rate_basis, traits: [:unit_range]
    factory :per_cbm_range_rate_basis, traits: [:cbm_range]
    factory :per_wm_range_rate_basis, traits: [:wm_range]
    factory :per_container_range_flat_rate_basis, traits: [:container_range_flat]
    factory :per_unit_range_flat_rate_basis, traits: [:unit_range_flat]
    factory :per_cbm_range_flat_rate_basis, traits: [:cbm_range_flat]
    factory :per_wm_range_flat_rate_basis, traits: [:wm_range_flat]
  end
end

# == Schema Information
#
# Table name: pricings_rate_bases
#
#  id            :uuid             not null, primary key
#  description   :string
#  external_code :string
#  internal_code :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sandbox_id    :uuid
#
# Indexes
#
#  index_pricings_rate_bases_on_external_code  (external_code)
#  index_pricings_rate_bases_on_sandbox_id     (sandbox_id)
#
