# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_parsed, class: 'Hash' do
    data_extraction_method { '' }
    rows_data { [] }

    initialize_with do
      { 'Sheet1' => attributes.deep_dup }
    end

    trait :one_col_fee_and_ranges do
      data_extraction_method { 'one_col_fee_and_ranges' }
    end

    trait :dynamic_fee_cols_no_ranges do
      data_extraction_method { 'dynamic_fee_cols_no_ranges' }
    end

    trait :correct_pricings do
      rows_data do
        [{ uuid: '575cc33f-41f6-45bb-9a71-46dbc777f146',
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
           range_min: nil,
           range_max: nil,
           fee_code: 'BAS',
           fee_name: 'Bas',
           currency: 'USD',
           fee_min: 17,
           fee: 17,
           row_nr: 2 }]
      end
    end

    trait :faulty_pricings do
      rows_data do
        [{ uuid: '575cc33f-41f6-45bb-9a71-46dbc777f146',
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
           wrooong: 'LCL',
           rate_basis: 'PER_WM',
           range_min: nil,
           range_max: nil,
           fee_code: 'BAS',
           fee_name: 'Bas',
           currency: 'USD',
           fee_min: 17,
           fee: 17,
           row_nr: 2 }]
      end
    end

    trait :correct_local_charges do
      rows_data do
        [{ uuid: '1e51dc52-56f4-4abe-9c68-e40839167516',
           hub: 'Bremerhaven',
           country: 'Germany',
           effective_date: Date.parse('2019-01-24'),
           expiration_date: Date.parse('2020-01-24'),
           counterpart_hub: nil,
           counterpart_country: nil,
           service_level: 'standard',
           carrier: 'SACO Shipping',
           fee_code: 'DOC',
           fee: 'Documentation',
           mot: 'ocean',
           load_type: 'lcl',
           direction: 'export',
           currency: 'EUR',
           rate_basis: 'PER_BILL',
           minimum: nil,
           maximum: nil,
           base: nil,
           ton: nil,
           cbm: nil,
           kg: nil,
           item: nil,
           shipment: nil,
           bill: 20,
           container: nil,
           wm: nil,
           range_min: nil,
           range_max: nil,
           dangerous: nil,
           row_nr: 2 }]
      end
    end

    trait :faulty_local_charges do
      rows_data do
        [{ uuid: '1e51dc52-56f4-4abe-9c68-e40839167516',
           hubbbbbbbbbbbb: 'Bremerhaven',
           country: 'Germany',
           effective_date: Date.parse('2019-01-24'),
           expiration_date: Date.parse('2020-01-24'),
           counterpart_hub: nil,
           counterpart_country: nil,
           service_level: 'standard',
           carrier: 'SACO Shipping',
           fee_code: 'DOC',
           fee: 'Documentation',
           mot: 'ocean',
           load_type: 'lcl',
           direction: 'export',
           currency: 'EUR',
           rate_basis: 'PER_BILL',
           minimum: nil,
           maximum: nil,
           base: nil,
           ton: 20,
           cbm: nil,
           kg: nil,
           item: nil,
           shipment: nil,
           bill: nil,
           container: nil,
           wm: nil,
           range_min: nil,
           range_max: nil,
           dangerous: nil,
           row_nr: 2 }]
      end
    end

    factory :excel_data_parsed_correct_pricings, traits: %i(one_col_fee_and_ranges correct_pricings)
    factory :excel_data_parsed_faulty_pricings, traits: %i(one_col_fee_and_ranges faulty_pricings)
    factory :excel_data_parsed_correct_local_charges, traits: %i(one_col_fee_and_ranges correct_local_charges)
    factory :excel_data_parsed_faulty_local_charges, traits: %i(one_col_fee_and_ranges faulty_local_charges)
  end
end
