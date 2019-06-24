# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_local_charge, class: 'Legacy::LocalCharge' do
    association :hub, factory: :legacy_hub
    association :tenant_vehicle, factory: :legacy_tenant_vehicle
    direction { 'export' }
    load_type { 'lcl' }
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
  end
end
