# frozen_string_literal: true

FactoryBot.define do
  factory :rates_fee, class: 'Rates::Fee' do
    association :cargo, factory: :rates_cargo
    amount_cents { 2500 }
    level { 0 }
    operator { :addition }
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
    end

    trait :stowage_basis do
      rate_basis { 16 }
    end

    trait :wm_basis do
      rate_basis { 6 }
    end

    trait :max do
      max_cents { 100 }
    end

    trait :cbm_basis do
      rate_basis { 3 }
    end

    trait :unit_basis do
      rate_basis { 17 }
    end

    trait :shipment_basis do
      rate_basis { 0 }
    end

    trait :km_basis do
      rate_basis { 18 }
    end

    trait :percentage do
      operator { :percentage }
    end
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
