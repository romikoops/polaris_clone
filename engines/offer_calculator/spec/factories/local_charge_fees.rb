# frozen_string_literal: true

FactoryBot.define do
  factory :local_charge_fees, class: 'Hash' do
    skip_create

    initialize_with { data.with_indifferent_access }

    trait :fcl do
      data do
        { 'ADI' => { 'key' => 'ADI', 'max' => nil, 'min' => nil, 'name' => 'Admin Fee', 'value' => 27.5, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
          'ECA' => { 'key' => 'ECA', 'max' => nil, 'min' => nil, 'name' => 'ECA/LSF', 'value' => 50, 'currency' => 'USD', 'rate_basis' => 'PER_CONTAINER', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
          'FILL' =>
       { 'key' => 'FILL', 'max' => nil, 'min' => nil, 'name' => 'Filling Charges', 'value' => 35, 'currency' => 'EUR', 'rate_basis' => 'PER_CONTAINER', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
          'ISPS' => { 'key' => 'ISPS', 'max' => nil, 'min' => nil, 'name' => 'ISPS', 'value' => 25, 'currency' => 'EUR', 'rate_basis' => 'PER_CONTAINER', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' } }
      end
    end

    trait :lcl do
      data do
        {
          'ADI' => { 'key' => 'ADI', 'max' => nil, 'min' => nil, 'name' => 'Admin Fee', 'value' => 27.5, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
          'ECA' => { 'key' => 'ECA', 'max' => nil, 'min' => nil, 'name' => 'ECA/LSF', 'value' => 0.5, 'currency' => 'USD', 'rate_basis' => 'PER_KG', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
          'FILL' => { 'key' => 'FILL', 'max' => nil, 'min' => nil, 'name' => 'Filling Charges', 'value' => 35, 'currency' => 'EUR', 'rate_basis' => 'PER_WM', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
          'ISPS' => { 'key' => 'ISPS', 'max' => nil, 'min' => nil, 'name' => 'ISPS', 'value' => 25, 'currency' => 'EUR', 'rate_basis' => 'PER_ITEM', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
          'QDF' =>
              {
                'key' => 'QDF',
                'max' => nil,
                'min' => 5,
                'name' => 'Wharfage / Quay Dues',
                'range' => [{ 'max' => 5, 'min' => 0, 'ton' => 41, 'currency' => 'EUR' }, { 'cbm' => 8, 'max' => 40, 'min' => 6, 'currency' => 'EUR' }],
                'currency' => 'EUR',
                'rate_basis' => 'PER_UNIT_TON_CBM_RANGE'
              }
        }
      end
    end

    factory :lcl_local_charge_fees_hash, traits: [:lcl]
    factory :fcl_local_charge_fees_hash, traits: [:fcl]
  end
end
