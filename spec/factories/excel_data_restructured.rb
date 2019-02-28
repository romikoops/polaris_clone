# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_restructured, class: 'Array' do
    initialize_with { attributes[:data] }

    trait :correct_pricings do
      data do
        [[{ sheet_name: 'Sheet1',
            data_extraction_method: 'one_col_fee_and_ranges',
            uuid: '575cc33f-41f6-45bb-9a71-46dbc777f146',
            effective_date: Date.parse('Thu, 15 Mar 2018'),
            expiration_date: Date.parse('Sun, 17 Mar 2019'),
            customer_email: nil,
            origin: 'Gothenburg',
            country_origin: 'Sweden',
            destination: 'Shanghai',
            country_destination: 'China',
            mot: 'ocean',
            carrier: nil,
            service_level: 'standard',
            load_type: 'LCL',
            rate_basis: 'PER_WM',
            fee_code: 'BAS',
            fee_name: 'Bas',
            currency: 'USD',
            fee_min: 17,
            fee: 17,
            row_nr: 2 }]]
      end
    end

    trait :faulty_pricings do
      data do
        [[{ sheet_name: 'Sheet1',
            data_extraction_method: 'one_col_fee_and_ranges',
            uuid: '12345-abcde-DIFFERENT!!',
            effective_date: Date.parse('Thu, 15 Mar 2018'),
            expiration_date: Date.parse('Sun, 17 Mar 2019'),
            customer_email: nil,
            origin: 'Gothenburg',
            country_origin: 'Sweden',
            destination: 'Shanghai',
            country_destination: 'China',
            mot: 'ocean',
            carrier: nil,
            service_level: 'standard',
            load_type: 'LCL',
            rate_basis: 'PER_WM',
            fee_code: 'BAS',
            fee_name: 'Bas',
            currency: 'USD',
            fee_min: 17,
            fee: 17,
            row_nr: 2 }]]
      end
    end

    trait :correct_local_charges do
      data do
        [{ uuid: '1e51dc52-56f4-4abe-9c68-e40839167516',
           hub: 'Bremerhaven',
           country: 'Germany',
           effective_date: Date.parse('Thu, 24 Jan 2019'),
           expiration_date: Date.parse('Fri, 24 Jan 2020'),
           counterpart_hub: nil,
           counterpart_country: nil,
           service_level: 'standard',
           carrier: 'SACO Shipping',
           mot: 'ocean',
           load_type: 'lcl',
           direction: 'export',
           dangerous: nil,
           fees: { 'DOC' =>
            { currency: 'EUR',
              key: 'DOC',
              min: nil,
              max: nil,
              name: 'Documentation',
              rate_basis: 'PER_BILL',
              value: 20 } },
           hub_name: 'Bremerhaven Port',
           counterpart_hub_name: nil }]
      end
    end

    trait :faulty_local_charges do
      data do
        [
          { uuid: '12345-abcde-DIFFERENT!!',
            hub: 'Bremerhaven',
            country: 'Germany',
            mot: 'ocean',
            load_type: 'lcl',
            counterpart_hub_id: nil,
            direction: 'export',
            fees: { 'CMP' => { 'key' => 'CMP', 'max' => nil, 'min' => nil, 'name' => 'Compliance Fee', 'value' => 2.7, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT' },
                    'DOC' => { 'key' => 'DOC', 'max' => nil, 'min' => nil, 'name' => 'Documentation', 'value' => 20, 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' },
                    'ISP' => { 'key' => 'ISP', 'max' => nil, 'min' => nil, 'name' => 'ISPS', 'value' => 4.5, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT' },
                    'QDF' => { 'key' => 'QDF', 'max' => 125, 'min' => 55, 'ton' => 40, 'name' => 'Quay dues', 'currency' => 'EUR', 'rate_basis' => 'PER_TON' },
                    'SOL' => { 'key' => 'SOL', 'max' => nil, 'min' => nil, 'name' => 'SOLAS Fee', 'value' => 7.5, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT' },
                    'ZAP' => { 'key' => 'ZAP', 'max' => nil, 'min' => nil, 'name' => 'Zapp', 'value' => 13, 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' } },
            dangerous: nil,
            effective_date: Date.parse('Thu, 24 Jan 2019'),
            expiration_date: Date.parse('Fri, 24 Jan 2020'),
            hub_name: 'Bremerhaven Port',
            counterpart_hub_name: nil }
        ]
      end
    end

    factory :excel_data_restructured_correct_pricings, traits: %i(correct_pricings)
    factory :excel_data_restructured_faulty_pricings, traits: %i(faulty_pricings)
    factory :excel_data_restructured_correct_local_charges, traits: %i(correct_local_charges)
    factory :excel_data_restructured_faulty_local_charges, traits: %i(faulty_local_charges)
  end
end
