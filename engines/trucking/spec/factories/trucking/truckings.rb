# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_trucking, class: 'Trucking::Trucking' do
    association :hub, factory: :legacy_hub
    association :location, factory: :zipcode_location
    association :tenant_vehicle, factory: :legacy_tenant_vehicle
    cbm_ratio { 460 }
    modifier { 'kg' }
    load_meterage { { 'ratio' => 1850.0, 'height_limit' => 130 }.freeze }
    rates do
      {
        kg: [
          {
            rate: { base: 100.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '200.0',
            min_kg: '0.1',
            min_value: 400.0
          },
          {
            rate: { base: 100.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '300.0',
            min_kg: '200.0',
            min_value: 400.0
          },
          {
            rate: { base: 100.0, value: 135.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '400.0',
            min_kg: '300.0',
            min_value: 400.0
          },
          {
            rate: { base: 100.0, value: 135.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '500.0',
            min_kg: '400.0',
            min_value: 400.0
          },
          {
            rate: { base: 100.0, value: 109.090909090909, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '600.0',
            min_kg: '500.0',
            min_value: 400.0
          },
          {
            rate: { base: 100.0, value: 110.769230769231, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '700.0',
            min_kg: '600.0',
            min_value: 400.0
          },
          {
            rate: { base: 100.0, value: 106.25, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '800.0',
            min_kg: '700.0',
            min_value: 400.0
          },
          {
            rate: { base: 100.0, value: 106.25, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '900.0',
            min_kg: '800.0',
            min_value: 400.0
          },
          {
            rate: { base: 100.0, value: 106.25, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '1000.0',
            min_kg: '900.0',
            min_value: 400.0
          },
          {
            rate: { base: 100.0, value: 85.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '2500.0',
            min_kg: '1000.0',
            min_value: 400.0
          },
          {
            rate: { base: 100.0, value: 58.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
            max_kg: '5000.0',
            min_kg: '2500.0',
            min_value: 533.0
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
          'min' => 250.0,
          'currency' => 'CNY',
          'rate_basis' => 'PER_SHIPMENT'
        }
      }.freeze
    end
    association :organization, factory: :organizations_organization
    load_type { 'cargo_item' }
    cargo_class { 'lcl' }
    truck_type { 'default' }
    carriage { 'pre' }

    trait :fcl_20 do
      load_type { 'container' }
      cargo_class { 'fcl_20' }
      truck_type { 'chassis' }
    end

    trait :with_fees do
      fees do
        {
          'AFEE' => {
            'key' => 'AFEE',
            'name' => 'A Fee',
            'value' => 250.0,
            'min' => 250.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_SHIPMENT'
          },
          'BFEE' => {
            'key' => 'BFEE',
            'name' => 'B Fee',
            'value' => 250.0,
            'min' => 250.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_CONTAINER'
          },
          'CFEE' => {
            'key' => 'CFEE',
            'name' => 'C Fee',
            'value' => 250.0,
            'min' => 250.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_BILL'
          },
          'DFEE' => {
            'key' => 'DFEE',
            'name' => 'D Fee',
            'ton' => 25.0,
            'cbm' => 15.0,
            'min' => 35.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_CBM_TON'
          },
          'EFEE' => {
            'key' => 'EFEE',
            'name' => 'E Fee',
            'kg' => 25.0,
            'cbm' => 15.0,
            'min' => 35.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_CBM_KG'
          },
          'FFEE' => {
            'key' => 'FFEE',
            'name' => 'F Fee',
            'value' => 25.0,
            'min' => 25.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_WM'
          },
          'GFEE' => {
            'key' => 'GFEE',
            'name' => 'G Fee',
            'value' => 25.0,
            'min' => 25.0,
            'currency' => 'CNY',
            'rate_basis' => 'PERCENTAGE'
          },
          'HFEE' => {
            'key' => 'HFEE',
            'name' => 'H Fee',
            'value' => 25.0,
            'min' => 25.0,
            'currency' => 'CNY',
            'rate_basis' => 'PER_ITEM'
          },
          'IFEE' => {
            'key' => 'IFEE',
            'name' => 'I Fee',
            'value' => 1,
            'min' => 10,
            'currency' => 'CNY',
            'rate_basis' => 'PER_KG'
          },
          'JFEE' => {
            'key' => 'JFEE',
            'name' => 'J Fee',
            'value' => 1,
            'min' => 10,
            'base' => 100,
            'currency' => 'CNY',
            'rate_basis' => 'PER_X_KG'
          },
          'KFEE' => {
            'key' => 'KFEE',
            'name' => 'K Fee',
            'value' => 1,
            'min' => 10,
            'x_base' => 100,
            'base_value' => 100,
            'currency' => 'CNY',
            'rate_basis' => 'PER_X_KM'
          },
          'LFEE' => {
            'key' => 'LFEE',
            'name' => 'L Fee',
            'unit' => 10,
            'min' => 10,
            'km' => 1,
            'currency' => 'CNY',
            'rate_basis' => 'PER_CONTAINER_KM'
          },
          'MFEE' => {
            'key' => 'MFEE',
            'name' => 'M Fee',
            'min' => 10,
            'shipment' => 10,
            'kg' => 1,
            'currency' => 'CNY',
            'rate_basis' => 'PER_SHIPMENT_KG'
          },
          'NFEE' => {
            'key' => 'NFEE',
            'name' => 'N Fee',
            'min' => 15,
            'currency' => 'CNY',
            'rate_basis' => 'PER_UNIT_RANGE',
            'range' => [
              { 'min' => 0, 'max' => 5, 'rate' => 100 },
              { 'min' => 6, 'max' => 10, 'rate' => 80 },
              { 'min' => 11, 'max' => 15, 'rate' => 60 },
              { 'min' => 16, 'max' => 20, 'rate' => 60 }
            ]
          },
          'OFEE' => {
            'key' => 'OFEE',
            'name' => 'O Fee',
            'currency' => 'CNY',
            'min' => 15,
            'rate_basis' => 'PER_KG_RANGE',
            'range' => [
              { 'min' => 0, 'max' => 1000, 'rate' => 100 },
              { 'min' => 1000, 'max' => 5000, 'rate' => 80 },
              { 'min' => 5000, 'max' => 1000, 'rate' => 60 },
              { 'min' => 10_000, 'max' => 20_000, 'rate' => 60 }
            ]
          },
          'PFEE' => {
            'key' => 'PFEE',
            'name' => 'P Fee',
            'value' => 25.0,
            'min' => 25,
            'currency' => 'CNY',
            'rate_basis' => 'PER_CBM'
          }
        }.freeze
      end
    end

    trait :return_distance do
      identifier_modifier { 'return' }
    end

    trait :cbm_rates do
      modifier { 'cbm' }
      rates do
        {
          cbm: [
            {
              rate: { value: 237.5, currency: 'SEK', rate_basis: 'PER_SHIPMENT' },
              max_cbm: '5',
              min_cbm: '0',
              min_value: 400.0
            },
            {
              rate: { value: 237.5, currency: 'SEK', rate_basis: 'PER_SHIPMENT' },
              max_cbm: '5',
              min_cbm: '10',
              min_value: 400.0
            },
            {
              rate: { value: 135.0, currency: 'SEK', rate_basis: 'PER_SHIPMENT' },
              max_cbm: '10',
              min_cbm: '30',
              min_value: 400.0
            }
          ]
        }
      end
    end

    trait :cbm_kg_rates do
      modifier { 'cbm_kg' }
      rates do
        {
          cbm: [
            {
              rate: { value: 237.5, currency: 'SEK', rate_basis: 'PER_SHIPMENT' },
              max_cbm: '5',
              min_cbm: '0.1',
              min_value: 400.0
            },
            {
              rate: { value: 237.5, currency: 'SEK', rate_basis: 'PER_SHIPMENT' },
              max_cbm: '5',
              min_cbm: '10',
              min_value: 400.0
            },
            {
              rate: { value: 135.0, currency: 'SEK', rate_basis: 'PER_SHIPMENT' },
              max_cbm: '10',
              min_cbm: '30',
              min_value: 400.0
            }
          ],
          kg: [
            {
              rate: { base: 100.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_X_KG' },
              max_kg: '500.0',
              min_kg: '100.0',
              min_value: 400.0
            },
            {
              rate: { base: 100.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_X_KG' },
              max_kg: '1000.0',
              min_kg: '500.0',
              min_value: 400.0
            },
            {
              rate: { base: 100.0, value: 135.0, currency: 'SEK', rate_basis: 'PER_X_KG' },
              max_kg: '2500.0',
              min_kg: '1000.0',
              min_value: 400.0
            }
          ]
        }
      end
    end

    trait :wm_rates do
      modifier { 'wm' }
      rates do
        {
          wm: [
            {
              rate: { value: 100, currency: 'SEK', rate_basis: 'PER_WM' },
              min_wm: '0',
              max_wm: '5',
              min_value: 400.0
            },
            {
              rate: { value: 100, currency: 'SEK', rate_basis: 'PER_WM' },
              min_wm: '5.000001',
              max_wm: '15',
              min_value: 200.0
            }
          ]
        }
      end
    end

    trait :forced_min_value do
      modifier { 'wm' }
      rates do
        {
          wm: [
            {
              rate: { value: 100, currency: 'SEK', rate_basis: 'PER_WM' },
              min_wm: '0',
              max_wm: '15',
              min_value: 1_000_000
            }
          ]
        }
      end
    end

    trait :unit_rates do
      modifier { 'unit' }
      rates do
        {
          unit: [
            {
              rate: { value: 100, currency: 'SEK', rate_basis: 'PER_UNIT' },
              min_unit: '0',
              max_unit: '10',
              min_value: 400.0
            }
          ]
        }
      end
    end

    trait :unit_per_km_rates do
      modifier { 'unit_per_km' }
      rates do
        {
          unit: [
            {
              rate: { value: 100, currency: 'SEK', rate_basis: 'PER_UNIT' },
              max_unit: '0',
              min_unit: '10',
              min_value: 400.0
            }
          ],
          km: [
            {
              rate: { value: 1, currency: 'SEK', rate_basis: 'PER_KM' },
              max_km: '0',
              min_km: '1000',
              min_value: 400.0
            }
          ]
        }
      end
    end

    trait :kg_cbm_special_rates do
      modifier { 'kg_cbm_special' }
      rates do
        {
          kg: [
            {
              rate: { value: 1, currency: 'SEK', rate_basis: 'PER_KG' },
              max_unit: '0',
              min_unit: '10000',
              min_value: 400.0
            }
          ],
          kg_sub: [
            {
              rate: { value: 10, currency: 'SEK', rate_basis: 'PER_KG' },
              max_unit: '0',
              min_unit: '10',
              min_value: 400.0
            }
          ],
          kg_base: [
            {
              rate: { value: 10, currency: 'SEK', rate_basis: 'PER_KG' },
              max_unit: '0',
              min_unit: '10',
              min_value: 400.0
            }
          ],
          cbm: [
            {
              rate: { value: 1, currency: 'SEK', rate_basis: 'PER_CBM' },
              max_unit: '0',
              min_unit: '10',
              min_value: 400.0
            }
          ],
          cbm_sub: [
            {
              rate: { value: 10, currency: 'SEK', rate_basis: 'PER_CBM' },
              max_unit: '0',
              min_unit: '10',
              min_value: 400.0
            }
          ],
          cbm_base: [
            {
              rate: { value: 10, currency: 'SEK', rate_basis: 'PER_CBM' },
              max_unit: '0',
              min_unit: '10',
              min_value: 400.0
            }
          ]

        }
      end
    end

    trait :unit_and_kg do
      modifier { 'unit_and_kg' }
      rates do
        {
          unit_in_kg: [
            {
              rate: { value: 100, currency: 'SEK', rate_basis: 'PER_UNIT_KG' },
              max_unit_in_kg: '1000',
              min_unit_in_kg: '0',
              min_value: 400.0
            },
            {
              rate: { value: 100, currency: 'SEK', rate_basis: 'PER_UNIT_KG' },
              max_unit_in_kg: '2000',
              min_unit_in_kg: '1001',
              min_value: 400.0
            }
          ],
          kg: [
            {
              rate: { base: 100.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_UNIT_KG' },
              max_kg: '500.0',
              min_kg: '100.0',
              min_value: 400.0
            },
            {
              rate: { base: 100.0, value: 237.5, currency: 'SEK', rate_basis: 'PER_UNIT_KG' },
              max_kg: '1000.0',
              min_kg: '500.0',
              min_value: 400.0
            },
            {
              rate: { base: 100.0, value: 135.0, currency: 'SEK', rate_basis: 'PER_UNIT_KG' },
              max_kg: '2500.0',
              min_kg: '1000.0',
              min_value: 400.0
            }
          ]
        }
      end
    end

    after(:create) do |trucking|
      trucking.fees.each do |key, fee|
        next if Legacy::ChargeCategory.exists?(organization: trucking.organization, code: key.downcase)

        FactoryBot.create(:legacy_charge_categories, organization: trucking.organization, code: key.downcase, name: fee['name'])
      end
    end

    factory :fcl_20_trucking, traits: [:fcl_20]
    factory :fcl_20_unit_trucking, traits: %i[fcl_20 unit_rates]
    factory :trucking_with_fees, traits: [:with_fees]
    factory :trucking_with_return, traits: [:return_distance]

    factory :trucking_with_forced_min, traits: [:forced_min_value]
    factory :trucking_with_cbm_rates, traits: [:cbm_rates]
    factory :trucking_with_cbm_kg_rates, traits: [:cbm_kg_rates]
    factory :trucking_with_wm_rates, traits: [:wm_rates]
    factory :trucking_with_unit_rates, traits: [:unit_rates]
    factory :trucking_with_unit_and_kg, traits: [:unit_and_kg]
    factory :trucking_with_unit_per_km, traits: [:unit_per_km_rates]
    factory :trucking_with_kg_cbm_special, traits: [:kg_cbm_special_rates]
  end
end

# == Schema Information
#
# Table name: trucking_truckings
#
#  id                  :uuid             not null, primary key
#  cargo_class         :string
#  carriage            :string
#  cbm_ratio           :integer
#  fees                :jsonb
#  identifier_modifier :string
#  load_meterage       :jsonb
#  load_type           :string
#  metadata            :jsonb
#  modifier            :string
#  rates               :jsonb
#  truck_type          :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  courier_id          :uuid
#  group_id            :uuid
#  hub_id              :integer
#  location_id         :uuid
#  old_user_id         :integer
#  organization_id     :uuid
#  parent_id           :uuid
#  rate_id             :uuid
#  sandbox_id          :uuid
#  tenant_id           :integer
#  tenant_vehicle_id   :integer
#  user_id             :integer
#
# Indexes
#
#  index_trucking_truckings_on_cargo_class        (cargo_class)
#  index_trucking_truckings_on_carriage           (carriage)
#  index_trucking_truckings_on_group_id           (group_id)
#  index_trucking_truckings_on_hub_id             (hub_id)
#  index_trucking_truckings_on_load_type          (load_type)
#  index_trucking_truckings_on_location_id        (location_id)
#  index_trucking_truckings_on_sandbox_id         (sandbox_id)
#  index_trucking_truckings_on_tenant_id          (tenant_id)
#  index_trucking_truckings_on_tenant_vehicle_id  (tenant_vehicle_id)
#  trucking_foreign_keys                          (rate_id,location_id,hub_id) UNIQUE
#
