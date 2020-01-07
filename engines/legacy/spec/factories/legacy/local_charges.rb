# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_local_charge, class: 'Legacy::LocalCharge' do
    association :hub, factory: :legacy_hub
    association :tenant_vehicle, factory: :legacy_tenant_vehicle
    direction { 'export' }
    load_type { 'lcl' }
    mode_of_transport { 'ocean' }
    effective_date { Date.today }
    expiration_date { Date.today + 6.months }
    fees do
      {
        'SOLAS' => {
          'key' => 'SOLAS',
          'max' => nil,
          'min' => 17.5,
          'name' => 'SOLAS',
          'value' => 17.5,
          'currency' => 'EUR',
          'rate_basis' => 'PER_SHIPMENT'
        }
      }
    end

    trait :range do
      fees do
        {
          "QDF"=>
            {"key"=>"QDF",
              "max"=>nil,
              "min"=>57,
              "name"=>"Wharfage / Quay Dues",
              "range"=>[{"max"=>5, "min"=>0, "ton"=>41, "currency"=>"EUR"}, {"cbm"=>8, "max"=>40, "min"=>6, "currency"=>"EUR"}],
              "currency"=>"EUR",
              "rate_basis"=>"PER_UNIT_TON_CBM_RANGE"},
        }
      end
    end

    factory :local_charge_range, traits: [:range]
  end
end
