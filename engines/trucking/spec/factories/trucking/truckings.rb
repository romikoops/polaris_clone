# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_trucking, class: 'Trucking::Trucking' do
    association :hub, factory: :legacy_hub
    association :location, factory: :trucking_location, zipcode: '43813'
    cbm_ratio { 460 }
    modifier { 'kg' }
    load_meterage { { 'ratio' => 1850.0, 'height_limit' => 130 }.freeze }
    rates do
      {
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
    end
    fees do
      {
        'PUF' => {
          'key' => 'PUF',
          'name' => 'Pickup Fee',
          'value' => 250.0,
          'currency' => 'CNY',
          'rate_basis' => 'PER_SHIPMENT'
        }
      }.freeze
    end
    association :tenant, factory: :legacy_tenant
    load_type { 'cargo_item' }
    cargo_class { 'lcl' }
    truck_type { 'default' }
    carriage { 'pre' }
    association :courier, factory: :trucking_courier

    trait :with_fees do
      fees do
        {
          'AFEE' => {
            'key' => 'AFEE',
            'name' => 'Pickup Fee',
            'value' => 250.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_SHIPMENT'
          },
          'BFEE' => {
            'key' => 'BFEE',
            'name' => 'Pickup Fee',
            'value' => 250.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_CONTAINER'
          },
          'CFEE' => {
            'key' => 'CFEE',
            'name' => 'Pickup Fee',
            'value' => 250.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_BILL'
          },
          'DFEE' => {
            'key' => 'DFEE',
            'name' => 'Pickup Fee',
            'ton' => 25.0,
            'cbm' => 15.0,
            'min' => 35.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_CBM_TON'
          },
          'EFEE' => {
            'key' => 'EFEE',
            'name' => 'Pickup Fee',
            'kg' => 25.0,
            'cbm' => 15.0,
            'min' => 35.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_CBM_KG'
          },
          'FFEE' => {
            'key' => 'FFEE',
            'name' => 'Pickup Fee',
            'value' => 25.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_WM'
          },
          'GFEE' => {
            'key' => 'GFEE',
            'name' => 'Pickup Fee',
            'value' => 25.0,
            'currency' => 'CNY',
            'rate_basis' => 'PERCENTAGE'
          },
          'HFEE' => {
            'key' => 'GFEE',
            'name' => 'Pickup Fee',
            'value' => 25.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_ITEM'
          }
        }.freeze
      end
    end

    trait :return_distance do
      identifier_modifier { 'return' }
    end

    factory :trucking_with_fees, traits: [:with_fees]
    factory :trucking_with_return, traits: [:return_distance]
  end
end
