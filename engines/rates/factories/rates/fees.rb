# frozen_string_literal: true

FactoryBot.define do
  factory :rates_fee, class: 'Rates::Fee' do
    association :cargo, factory: :rates_cargo
    amount_cents { 2500 }
    level { 0 }
    operator { 0 }
    amount_currency { 'USD' }
    rate_basis { 0 }
    kg_range { (0..Float::INFINITY) }
    stowage_range { (0..Float::INFINITY) }
    km_range { (0..Float::INFINITY) }
    cbm_range { (0..Float::INFINITY) }
    wm_range { (0..Float::INFINITY) }
    unit_range { (0..Float::INFINITY) }
    validity { (4.days.ago..60.days.from_now) }
    min_amount_cents { 100 }
    min_amount_currency { 'USD' }
    max_amount_cents { 1_000_000 }
    max_amount_currency { 'USD' }
    cbm_ratio { 1000 }

    trait :kg_basis do
      rate_basis { 4 }
      kg_range { 5..10 }
    end

    trait :stowage_basis do
      rate_basis { 5 }
      stowage_range { 5..10 }
    end

    trait :wm_basis do
      rate_basis { 1 }
      wm_range { 5..10 }
    end

    trait :max do
      max_cents { 100 }
    end

    trait :cbm_basis do
      rate_basis { 3 }
      cbm_range { 5..10 }
    end

    trait :unit_basis do
      rate_basis { 6 }
      unit_range { 5..10 }
    end

    trait :shipment_basis do
      min_amount_cents { 0 }
      max_amount_cents { 100 }
      rate_basis { :shipment }
    end

    trait :percentage_basis do
      min_amount_cents { 0 }
      max_amount_cents { 100 }
      rate_basis { :percentage }
    end

    trait :km_basis do
      rate_basis { 7 }
      km_range { (0..Float::INFINITY) }
    end

    trait :multiplication do
      operator { :multiplication }
    end

    factory :unit_based_fee, traits: %i[unit_basis]
    factory :km_based_fee, traits: %i[km_basis]
    factory :cbm_based_fee, traits: %i[cbm_basis]
    factory :wm_based_fee, traits: %i[wm_basis]
    factory :stowage_based_fee, traits: %i[stowage_basis]
    factory :kg_based_fee, traits: %i[kg_basis]
  end
end

# == Schema Information
#
# Table name: rates_fees
#
#  id                  :uuid             not null, primary key
#  amount_cents        :bigint           default(0), not null
#  amount_currency     :string           not null
#  cbm_range           :numrange
#  cbm_ratio           :decimal(, )      default(1000.0)
#  kg_range            :numrange
#  km_range            :numrange
#  level               :integer          default(0), not null
#  max_amount_cents    :bigint           default(0), not null
#  max_amount_currency :string           not null
#  min_amount_cents    :bigint           default(0), not null
#  min_amount_currency :string           not null
#  operator            :integer          default("addition"), not null
#  rate_basis          :integer          default("shipment"), not null
#  rule                :jsonb
#  stowage_range       :numrange
#  unit_range          :numrange
#  validity            :daterange
#  wm_range            :numrange
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  cargo_id            :uuid
#
# Indexes
#
#  index_rates_fees_on_cargo_id  (cargo_id)
#
# Foreign Keys
#
#  fk_rails_...  (cargo_id => rates_cargos.id)
#
