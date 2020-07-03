# frozen_string_literal: true

FactoryBot.define do
  factory :customs_fee do
    load_type { 'lcl' }
    mode_of_transport { 'ocean' }
    association :organization, factory: :organizations_organization
    association :tenant_vehicle
    counterpart_hub_id { nil }
    direction { 'export' }
    fees do
      {
        'CUST' => {
          'key' => 'CUST',
          'max' => nil,
          'name' => 'Customs Clearance',
          'value' => 150.0,
          'currency' => 'CNY',
          'rate_basis' => 'PER_SHIPMENT',
          'effective_date' => '2018-12-13',
          'expiration_date' => '2018-12-31'
        }
      }
    end
  end
end
