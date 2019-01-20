# frozen_string_literal:true

RATES = {
  kg: [
    {
      rate: { base: 100.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '200.0',
      min_kg: '101.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '300.0',
      min_kg: '201.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 135.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '400.0',
      min_kg: '301.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 135.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '500.0',
      min_kg: '401.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 109.090909090909, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '600.0',
      min_kg: '501.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 110.769230769231, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '700.0',
      min_kg: '601.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 106.25, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '800.0',
      min_kg: '701.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 106.25, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '900.0',
      min_kg: '801.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 106.25, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '1000.0',
      min_kg: '901.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 85.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '2500.0',
      min_kg: '1001.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 58.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '5000.0',
      min_kg: '2501.0',
      min_value: 533.0
    },
    {
      rate: { base: 100.0, value: 58.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '6000.0',
      min_kg: '5001.0',
      min_value: 533.0
    },
    {
      rate: { base: 100.0, value: 40.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '10000.0',
      min_kg: '6001.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 30.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '15000.0',
      min_kg: '10001.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 28.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '20000.0',
      min_kg: '15001.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 27.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '25000.0',
      min_kg: '20001.0',
      min_value: 400.0
    },
    {
      rate: { base: 100.0, value: 26.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
      max_kg: '39000.0',
      min_kg: '25001.0',
      min_value: 400
    }
  ]
}.freeze

FEES = {
  'PUF' => {
    'key' => 'PUF',
    'name' => 'Pickup Fee',
    'value' => 250.0,
    'currency' => 'CNY',
    'rate_basis' => 'PER_SHIPMENT'
  }
}.freeze

LOAD_METERAGE = { 'ratio' => 1850.0, 'height_limit' => 130 }.freeze

FactoryBot.define do
  factory :trucking_pricing do
    association :trucking_pricing_scope
    cbm_ratio { 460 }
    modifier { 'kg' }
    load_meterage { LOAD_METERAGE }
    rates { RATES }
    fees { FEES }
    association :tenant
  end
end

# == Schema Information
#
# Table name: trucking_pricings
#
#  id                        :bigint(8)        not null, primary key
#  load_meterage             :jsonb
#  cbm_ratio                 :integer
#  modifier                  :string
#  tenant_id                 :integer
#  created_at                :datetime
#  updated_at                :datetime
#  rates                     :jsonb
#  fees                      :jsonb
#  identifier_modifier       :string
#  trucking_pricing_scope_id :integer
#
