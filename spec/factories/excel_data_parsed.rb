# frozen_string_literal: true

FactoryBot.define do
  factory :excel_data_parsed, class: 'Hash' do
    restructurer_name { '' }
    rows_data { [] }

    initialize_with do
      attributes[:all_sheets_data]
        .map { |per_sheet_data| per_sheet_data.merge(attributes[:restructurer_name]) }
        .deep_dup
    end

    trait :pricing_one_fee_col_and_ranges do
      restructurer_name { { restructurer_name: 'pricing_one_fee_col_and_ranges' } }
    end

    trait :pricing_dynamic_fee_cols_no_ranges do
      restructurer_name { { restructurer_name: 'pricing_dynamic_fee_cols_no_ranges' } }
    end

    trait :local_charges do
      restructurer_name { { restructurer_name: 'local_charges' } }
    end

    trait :saco_shipping do
      restructurer_name { { restructurer_name: 'saco_shipping' } }
    end

    trait :margins do
      restructurer_name { { restructurer_name: 'margins' } }
    end

    trait :max_dimensions do
      restructurer_name { { restructurer_name: 'max_dimensions' } }
    end

    trait :correct_pricings_one_fee_col_and_ranges do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
            [{ effective_date: Date.parse('Thu, 15 Mar 2018'),
               expiration_date: Date.parse('Fri, 15 Nov 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               wm_ratio: 800,
               carrier: nil,
               service_level: 'standard',
               load_type: 'lcl',
               rate_basis: 'PER_WM',
               range_min: nil,
               range_max: nil,
               fee_code: 'BAS',
               fee_name: 'Bas',
               currency: 'USD',
               fee_min: 17,
               fee: 17,
               transit_time: 24,
               transshipment: 'ZACPT',
               row_nr: 2 },
             { effective_date: Date.parse('Thu, 15 Mar 2018'),
               expiration_date: Date.parse('Sun, 17 Mar 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               carrier: nil,
               service_level: 'standard',
               load_type: 'lcl',
               rate_basis: 'PER_WM',
               range_min: nil,
               range_max: nil,
               fee_code: 'BAS',
               fee_name: 'Bas',
               currency: 'USD',
               fee_min: 17,
               fee: 17,
               transit_time: 24,
               transshipment: nil,
               row_nr: 2 },
             { effective_date: Date.parse('Thu, 15 Nov 2018'),
               expiration_date: Date.parse('Sun, 17 Mar 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               carrier: nil,
               service_level: 'standard',
               load_type: 'lcl',
               rate_basis: 'PER_WM',
               range_min: nil,
               range_max: nil,
               fee_code: 'WAR',
               fee_name: 'War Risk Surcharge',
               currency: 'USD',
               fee_min: 2,
               fee: 2,
               transit_time: 24,
               transshipment: nil,
               row_nr: 2 },
             { effective_date: Date.parse('Thu, 30 Nov 2018'),
               expiration_date: Date.parse('Sun, 28 Mar 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               carrier: nil,
               service_level: 'standard',
               load_type: 'lcl',
               rate_basis: 'PER_WM',
               range_min: nil,
               range_max: nil,
               fee_code: 'ABC',
               fee_name: 'ABC Surcharge',
               currency: 'USD',
               fee_min: 500,
               fee: 500,
               transit_time: 24,
               transshipment: nil,
               row_nr: 2 },
             { effective_date: Date.parse('Thu, 11 Mar 2018'),
               expiration_date: Date.parse('Sun, 17 Mar 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               carrier: nil,
               service_level: 'standard',
               load_type: 'lcl',
               rate_basis: 'PER_WM',
               range_min: nil,
               range_max: nil,
               fee_code: 'BAS',
               fee_name: 'Bas',
               currency: 'USD',
               fee_min: 17,
               fee: 17,
               transit_time: 24,
               transshipment: nil,
               row_nr: 2 },
             { effective_date: Date.parse('Thu, 11 Mar 2018'),
               expiration_date: Date.parse('Sun, 17 Mar 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               carrier: nil,
               service_level: 'standard',
               load_type: 'lcl',
               rate_basis: 'PER_WM',
               range_min: 0,
               range_max: 100,
               fee_code: 'HAS',
               fee_name: 'Has',
               currency: 'USD',
               fee_min: 20,
               fee: 20,
               transit_time: 24,
               transshipment: nil,
               row_nr: 3 },
             { effective_date: Date.parse('Thu, 11 Mar 2018'),
               expiration_date: Date.parse('Sun, 17 Mar 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               carrier: nil,
               service_level: 'standard',
               load_type: 'lcl',
               rate_basis: 'PER_WM',
               range_min: 101,
               range_max: 500,
               fee_code: 'HAS',
               fee_name: 'Has',
               currency: 'USD',
               fee_min: 25,
               fee: 25,
               transit_time: 24,
               transshipment: nil,
               row_nr: 4 },
             { effective_date: Date.parse('Thu, 15 Mar 2018'),
               expiration_date: Date.parse('Sun, 17 Mar 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               carrier: nil,
               service_level: 'standard',
               load_type: 'fcl',
               rate_basis: 'PER_CONTAINER',
               range_min: nil,
               range_max: nil,
               fee_code: 'BAS',
               fee_name: 'Bas',
               currency: 'USD',
               fee_min: 1234,
               fee: 1234,
               transit_time: 24,
               transshipment: nil,
               row_nr: 5 }] }]
      end
    end

    trait :correct_pricings_one_fee_col_and_ranges_with_remarks do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
            [{ effective_date: Date.parse('Thu, 15 Mar 2018'),
               expiration_date: Date.parse('Fri, 15 Nov 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               carrier: nil,
               service_level: 'standard',
               load_type: 'lcl',
               rate_basis: 'PER_WM',
               range_min: nil,
               range_max: nil,
               fee_code: 'BAS',
               fee_name: 'Bas',
               currency: 'USD',
               fee_min: 17,
               fee: 17,
               wm_rate: 800,
               transit_time: 24,
               transshipment: 'ZACPT',
               remarks: 'test',
               row_nr: 2 }]}]
      end
    end

    trait :to_upcase_pricings_one_fee_col_and_ranges do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
            [{ effective_date: Date.parse('Thu, 15 Mar 2018'),
               expiration_date: Date.parse('Fri, 15 Nov 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               carrier: nil,
               service_level: 'standard',
               load_type: 'lcl',
               rate_basis: 'PER_wm',
               range_min: nil,
               range_max: nil,
               fee_code: 'bas',
               fee_name: 'Bas',
               currency: 'USD',
               fee_min: 17,
               fee: 17,
               wm_ratio: 800,
               transit_time: 24,
               transshipment: 'ZACPT',
               row_nr: 2 }] }]
      end
    end

    trait :correct_pricings_dynamic_fee_cols_no_ranges do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
            [
              { effective_date: Date.parse('Fri, 01 Feb 2019'),
                expiration_date: Date.parse('Sun, 31 Mar 2019'),
                origin: 'Dalian',
                country_origin: 'China',
                destination: 'Gothenburg',
                country_destination: 'Sweden',
                mot: 'ocean',
                carrier: 'APL',
                service_level: 'Standard',
                load_type: 'FCL_40',
                rate_basis: 'PER_CONTAINER',
                transit_time: 42,
                currency: 'USD',
                bas: nil,
                lss: 60,
                rate: 1550,
                transshipment: 'ZACPT',
                row_nr: 2 },
              { effective_date: Date.parse('Fri, 01 Feb 2019'),
                expiration_date: Date.parse('Sun, 31 Mar 2019'),
                origin: 'Dalian',
                country_origin: 'China',
                destination: 'Gothenburg',
                country_destination: 'Sweden',
                mot: 'ocean',
                carrier: 'APL',
                service_level: 'Standard',
                load_type: 'FCL_40',
                rate_basis: 'PER_CONTAINER',
                transit_time: 42,
                currency: 'USD',
                bas: nil,
                lss: 60,
                rate: 1550,
                transshipment: nil,
                row_nr: 3 },
              { effective_date: Date.parse('Tue, 01 Jan 2019'),
                expiration_date: Date.parse('Sun, 31 Mar 2019'),
                origin: 'Hong Kong',
                country_origin: 'Hong Kong',
                destination: 'Southampton',
                country_destination: 'United Kingdom of Great Britain and Northern Ireland',
                mot: 'ocean',
                carrier: 'YML',
                service_level: 'standard',
                load_type: 'FCL_40_HQ',
                rate_basis: 'PER_CONTAINER',
                transit_time: 27,
                currency: 'USD',
                bas: nil,
                lss: 60,
                rate: 2550,
                transshipment: nil,
                row_nr: 4 }
            ] }]
      end
    end

    trait :correct_pricings_dynamic_fee_cols_no_ranges_with_remarks do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
            [
              { effective_date: Date.parse('Tue, 01 Jan 2019'),
                expiration_date: Date.parse('Sun, 31 Mar 2019'),
                origin: 'Hong Kong',
                country_origin: 'Hong Kong',
                destination: 'Southampton',
                country_destination: 'United Kingdom of Great Britain and Northern Ireland',
                mot: 'ocean',
                carrier: 'YML',
                service_level: 'standard',
                load_type: 'FCL_40_HQ',
                rate_basis: 'PER_CONTAINER',
                transit_time: 27,
                currency: 'USD',
                bas: nil,
                lss: 60,
                rate: 2550,
                transshipment: nil,
                remarks: 'Test',
                row_nr: 4 }
            ] }]
      end
    end

    trait :to_upcase_pricings_dynamic_fee_cols_no_ranges do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
            [
              { effective_date: Date.parse('Fri, 01 Feb 2019'),
                expiration_date: Date.parse('Sun, 31 Mar 2019'),
                origin: 'Dalian',
                country_origin: 'China',
                destination: 'Gothenburg',
                country_destination: 'Sweden',
                mot: 'ocean',
                carrier: 'APL',
                service_level: 'Standard',
                load_type: 'FCL_40',
                rate_basis: 'per_container',
                transit_time: 42,
                currency: 'USD',
                bas: nil,
                lss: 60,
                rate: 1550,
                transshipment: 'ZACPT',
                row_nr: 2 }
            ] }]
      end
    end

    trait :up_case_mot_pricings_dynamic_fee_cols_no_ranges do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
            [
              { effective_date: Date.parse('Fri, 01 Feb 2019'),
                expiration_date: Date.parse('Sun, 31 Mar 2019'),
                origin: 'Dalian',
                country_origin: 'China',
                destination: 'Gothenburg',
                country_destination: 'Sweden',
                mot: 'OCEAN',
                carrier: 'APL',
                service_level: 'Standard',
                load_type: 'FCL_40',
                rate_basis: 'per_container',
                transit_time: 42,
                currency: 'USD',
                bas: nil,
                lss: 60,
                rate: 1550,
                transshipment: 'ZACPT',
                row_nr: 2 }
            ] }]
      end
    end

    trait :correct_local_charges do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
        [{ hub: 'Bremerhaven',
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
           row_nr: 2 },
         { hub: 'Antwerp',
           country: 'Belgium',
           effective_date: Date.parse('2019-01-24'),
           expiration_date: Date.parse('2020-01-24'),
           counterpart_hub: 'all',
           counterpart_country: nil,
           service_level: 'all',
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
           range_min: 0,
           range_max: 100,
           dangerous: nil,
           row_nr: 3 },
         { hub: 'Le Havre',
           country: 'France',
           effective_date: Date.parse('2019-01-24'),
           expiration_date: Date.parse('2020-01-24'),
           counterpart_hub: 'Antwerp',
           counterpart_country: 'Belgium',
           service_level: 'standard',
           carrier: 'all',
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
           row_nr: 4 }] }]
      end
    end

    trait :correct_local_charges_with_counterpart_expansion do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
        [{ hub: 'Bremerhaven',
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
           row_nr: 2 },
         { hub: 'Bremerhaven',
           country: 'Germany',
           effective_date: Date.parse('2019-01-24'),
           expiration_date: Date.parse('2020-01-24'),
           counterpart_hub: 'Gothenburg',
           counterpart_country: 'Sweden',
           service_level: 'standard',
           carrier: 'SACO Shipping',
           fee_code: 'THC',
           fee: 'Terminal Handling Charge',
           mot: 'ocean',
           load_type: 'lcl',
           direction: 'export',
           currency: 'EUR',
           rate_basis: 'PER_SHIPMENT',
           minimum: nil,
           maximum: nil,
           base: nil,
           ton: nil,
           cbm: nil,
           kg: nil,
           item: nil,
           shipment: 30,
           bill: nil,
           container: nil,
           wm: nil,
           range_min: nil,
           range_max: nil,
           dangerous: nil,
           row_nr: 3 },
         { hub: 'Le Havre',
           country: 'France',
           effective_date: Date.parse('2019-01-24'),
           expiration_date: Date.parse('2020-01-24'),
           counterpart_hub: 'Antwerp',
           counterpart_country: 'Belgium',
           service_level: 'standard',
           carrier: 'all',
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
           row_nr: 4 }] }]
      end
    end

    trait :correct_saco_shipping do
      all_sheets_data do
        [{ sheet_name: 'Africa',
           restructurer_name: 'saco_shipping',
           rows_data:
           [
             { internal: nil,
               destination_country: 'Angola',
               destination_hub: 'Cabinda',
               destination_locode: 'AOCAB',
               origin_locode: 'BE ANR',
               terminal: 'ABC TERMINAL',
               "transshipment_via": 'CGPNR',
               carrier: 'CMA CGM',
               effective_date: Date.parse('Mon, 01 Apr 2019'),
               expiration_date: Date.parse('Sat, 31 Aug 2019'),
               "int/ref_nr": 'FL4222-ERF-A-001',
               "20dc": Money.new(256_500, 'EUR'),
               "40dc": Money.new(411_500, 'EUR'),
               "40hq": Money.new(411_500, 'EUR'),
               "20/lsf": 'incl',
               "40/lsf": 'incl',
               "curr_month/baf": 'JUN',
               "curr_fee/20/baf": 'incl',
               "curr_fee/40/baf": 'incl',
               "next_month/baf": 'JUL',
               "next_fee/20/baf": 'incl',
               "next_fee/40/baf": 'incl',
               "curr_month/caf": 'OKT',
               "curr_fee/20/caf": Money.new(30, 'EUR'),
               "thc": Money.new(19_700, 'EUR'),
               "int/20/imo": 'n/a',
               "int/40/imo": 'n/a',
               "20/ebs": Money.new(4500, 'EUR'),
               "40/ebs": Money.new(9000, 'EUR'),
               "isps": Money.new(2700, 'EUR'),
               "40/dest/thc": Money.new(250, 'EUR'),
               "note/electronic_cargo_tracking_note/waiver_(ectn/besc)": 'x',
               "int/freetime_at_destination": nil,
               remarks: 'some remark',
               row_nr: 2 }
           ] }]
      end
    end

    trait :correct_margins do
      all_sheets_data do
        [{ sheet_name: 'Tabelle1',
           restructurer_name: 'margins',
           rows_data:
            [{ effective_date: Date.parse('Tue, 01 Jan 2019'),
               expiration_date: Date.parse('Sun, 31 Mar 2019'),
               origin: 'Dalian',
               country_origin: 'China',
               destination: 'Gothenburg',
               country_destination: 'Sweden',
               mot: 'ocean',
               carrier: 'Consolidation',
               service_level: 'standard',
               margin_type: 'freight',
               load_type: 'LCL',
               fee_code: 'BAS',
               operator: '+',
               margin: 0.1,
               row_nr: 2 },
             { effective_date: Date.parse('Tue, 01 Jan 2019'),
               expiration_date: Date.parse('Sun, 31 Mar 2019'),
               origin: 'Dalian',
               country_origin: 'China',
               destination: 'Gothenburg',
               country_destination: 'Sweden',
               mot: 'ocean',
               carrier: 'Consolidation',
               service_level: 'standard',
               margin_type: 'freight',
               load_type: 'LCL',
               fee_code: 'BAS',
               operator: '%',
               margin: 0.1,
               row_nr: 3 }] }]
      end
    end

    trait :upcase_mot_margins do
      all_sheets_data do
        [{ sheet_name: 'Tabelle1',
           restructurer_name: 'margins',
           rows_data:
            [{ effective_date: Date.parse('Tue, 01 Jan 2019'),
               expiration_date: Date.parse('Sun, 31 Mar 2019'),
               origin: 'Dalian',
               country_origin: 'China',
               destination: 'Gothenburg',
               country_destination: 'Sweden',
               mot: 'OCEAN',
               carrier: 'Consolidation',
               service_level: 'standard',
               margin_type: 'freight',
               load_type: 'LCL',
               fee_code: 'BAS',
               operator: '+',
               margin: 0.1,
               row_nr: 2 },
             { effective_date: Date.parse('Tue, 01 Jan 2019'),
               expiration_date: Date.parse('Sun, 31 Mar 2019'),
               origin: 'Dalian',
               country_origin: 'China',
               destination: 'Gothenburg',
               country_destination: 'Sweden',
               mot: 'OCEAN',
               carrier: 'Consolidation',
               service_level: 'standard',
               margin_type: 'freight',
               load_type: 'LCL',
               fee_code: 'BAS',
               operator: '%',
               margin: 0.1,
               row_nr: 3 }] }]
      end
    end

    trait :default_hubs do
      sheet_name { 'Hubs' }
      restructurer_name { 'hubs' }
      data do
        [{ status: 'active',
           type: 'OCEAN',
           name: 'Abu Dhabi',
           locode: 'AEAUH',
           latitude: nil,
           longitude: nil,
           country: 'United Arab Emirates',
           full_address: 'Khalifa Port - Abu Dhabi - United Arab Emirates',
           photo: nil,
           free_out: 'false',
           import_charges: 'true',
           export_charges: 'false',
           pre_carriage: nil,
           on_carriage: 'false',
           alternative_names: nil,
           terminal: 'ABD',
           terminal_code: '',
           row_nr: 2 },
         { status: 'active',
           type: 'ocean',
           name: 'Adelaide',
           locode: 'auadl',
           latitude: -34.9284989,
           longitude: 138.6007456,
           country: 'Australia',
           full_address: '202 Victoria Square, Adelaide SA 5000, Australia',
           photo: nil,
           free_out: 'false',
           import_charges: 'true',
           export_charges: 'false',
           pre_carriage: 'false',
           on_carriage: 'false',
           alternative_names: nil,
           terminal: 'ABD',
           terminal_code: '',
           row_nr: 3 }]
      end
    end

    trait :hubs_with_boolean_values do
      restructurer_name { { restructurer_name: 'hubs' } }
      all_sheets_data do
        [{
          sheet_name: 'Hubs',
          rows_data: [{ status: 'active',
                        type: 'OCEAN',
                        name: 'Abu Dhabi',
                        locode: 'AEAUH',
                        latitude: nil,
                        longitude: nil,

                        country: 'United Arab Emirates',
                        full_address: 'Khalifa Port - Abu Dhabi - United Arab Emirates',
                        photo: nil,
                        free_out: false,
                        import_charges: true,
                        export_charges: false,
                        pre_carriage: nil,
                        on_carriage: false,
                        alternative_names: nil,
                        terminal: 'ABD',
                        terminal_code: '',
                        row_nr: 2 }]
        }]
      end
    end

    trait :correct_max_dimensions do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           restructurer_name: 'max_dimensions',
           rows_data:
          [{ carrier: 'msc',
             service_level: 'standard',
             mode_of_transport: 'ocean',
             width: 0.1e4,
             length: 0.9e3,
             height: 0.12e4,
             payload_in_kg: 0.1e5,
             chargeable_weight: 0.1e5,
             load_type: 'lcl',
             aggregate: nil,
             origin_locode: nil,
             destination_locode: nil,
             row_nr: 2 },
           { carrier: 'msc',
             service_level: 'faster',
             mode_of_transport: 'ocean',
             width: 0.1e4,
             length: 0.9e3,
             height: 0.12e4,
             payload_in_kg: 0.1e5,
             chargeable_weight: 0.1e5,
             load_type: 'lcl',
             aggregate: true,
             origin_locode: nil,
             destination_locode: nil,
             row_nr: 3 },
           { carrier: 'msc',
             service_level: 'faster',
             mode_of_transport: 'ocean',
             width: 0,
             length: 0,
             height: 0,
             payload_in_kg: 0.1e6,
             load_type: 'fcl_20',
             aggregate: false,
             origin_locode: 'SEGOT',
             destination_locode: 'cnsha',
             row_nr: 4 }] }]
      end
    end

    trait :hubs_missing_lat_lon do
      restructurer_name { { restructurer_name: 'hubs' } }
      all_sheets_data do
        [{
          sheet_name: 'Hubs',
          rows_data: [{ status: 'active',
                        type: 'OCEAN',
                        name: 'Sultan Lake',
                        locode: 'AEAUH',
                        latitude: nil,
                        longitude: nil,
                        country: 'United Arab Emirates',
                        full_address: 'Khalifa Port - Abu Dhabi - United Arab Emirates',
                        photo: nil,
                        free_out: 'false',
                        import_charges: 'true',
                        export_charges: 'false',
                        pre_carriage: nil,
                        on_carriage: 'false',
                        alternative_names: nil,
                        row_nr: 2 }]
        }]
      end
    end

    trait :hubs_missing_address do
      restructurer_name { { restructurer_name: 'hubs' } }
      all_sheets_data do
        [{
          sheet_name: 'Hubs',
          rows_data: [{ status: 'active',
                        type: 'OCEAN',
                        name: 'Sultan Lake',
                        locode: 'AEAUH',
                        latitude: nil,
                        longitude: nil,
                        country: 'United Arab Emirates',
                        full_address: nil,
                        photo: nil,
                        free_out: 'false',
                        import_charges: 'true',
                        export_charges: 'false',
                        pre_carriage: nil,
                        on_carriage: 'false',
                        alternative_names: nil,
                        row_nr: 2 }]
        }]
      end
    end

    trait :to_upcase_pricings_one_fee_col_and_ranges do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
            [{ effective_date: Date.parse('Thu, 15 Mar 2018'),
               expiration_date: Date.parse('Fri, 15 Nov 2019'),
               origin: 'Gothenburg',
               country_origin: 'Sweden',
               destination: 'Shanghai',
               country_destination: 'China',
               mot: 'ocean',
               carrier: nil,
               service_level: 'standard',
               load_type: 'lcl',
               rate_basis: 'PER_wm',
               range_min: nil,
               range_max: nil,
               fee_code: 'bas',
               fee_name: 'Bas',
               currency: 'USD',
               fee_min: 17,
               fee: 17,
               transit_time: 24,
               transshipment: 'ZACPT',
               row_nr: 2 }] }]
      end
    end

    trait :to_upcase_pricings_dynamic_fee_cols_no_ranges do
      all_sheets_data do
        [{ sheet_name: 'Sheet1',
           rows_data:
            [
              { effective_date: Date.parse('Fri, 01 Feb 2019'),
                expiration_date: Date.parse('Sun, 31 Mar 2019'),
                origin: 'Dalian',
                country_origin: 'China',
                destination: 'Gothenburg',
                country_destination: 'Sweden',
                mot: 'ocean',
                carrier: 'APL',
                service_level: 'Standard',
                load_type: 'FCL_40',
                rate_basis: 'per_container',
                transit_time: 42,
                currency: 'USD',
                bas: nil,
                lss: 60,
                rate: 1550,
                transshipment: 'ZACPT',
                row_nr: 2 }
            ] }]
      end
    end

    factory :default_hubs_row_data, traits: %i[default_hubs]
    factory :excel_data_parsed_correct_pricings_one_fee_col_and_ranges,
      traits: %i[pricing_one_fee_col_and_ranges correct_pricings_one_fee_col_and_ranges]
    factory :excel_data_parsed_correct_pricings_one_fee_col_and_ranges_with_remarks,
      traits: %i[pricing_one_fee_col_and_ranges correct_pricings_one_fee_col_and_ranges_with_remarks]
    factory :excel_data_parsed_to_upcase_pricings_one_fee_col_and_ranges,
      traits: %i[pricing_one_fee_col_and_ranges to_upcase_pricings_one_fee_col_and_ranges]
    factory :excel_data_parsed_correct_pricings_dynamic_fee_cols_no_ranges,
      traits: %i[pricing_dynamic_fee_cols_no_ranges correct_pricings_dynamic_fee_cols_no_ranges]
    factory :excel_data_parsed_correct_pricings_dynamic_fee_cols_no_ranges_with_remarks,
      traits: %i[pricing_dynamic_fee_cols_no_ranges
     correct_pricings_dynamic_fee_cols_no_ranges_with_remarks]
    factory :excel_data_parsed_correct_local_charges, traits: %i[local_charges correct_local_charges]
    factory :excel_data_parsed_correct_local_charges_with_counterpart_expansion,
      traits: %i[local_charges correct_local_charges_with_counterpart_expansion]
    factory :excel_data_parsed_correct_saco_shipping, traits: %i[saco_shipping correct_saco_shipping]
    factory :excel_data_parsed_correct_margins, traits: %i[margins correct_margins]
    factory :excel_data_parsed_upcase_mot_margins, traits: %i[margins upcase_mot_margins]
    factory :excel_data_parsed_correct_max_dimensions, traits: %i[max_dimensions correct_max_dimensions]
    factory :hubs_missing_address_data, traits: %i[hubs_missing_address]
    factory :excel_data_parsed_to_upcase_pricings_dynamic_fee_cols_no_ranges,
      traits: %i[pricing_dynamic_fee_cols_no_ranges to_upcase_pricings_dynamic_fee_cols_no_ranges]
    factory :excel_data_parsed_upcase_mot_pricings_dynamic_fee_cols_no_ranges,
      traits: %i[pricing_dynamic_fee_cols_no_ranges up_case_mot_pricings_dynamic_fee_cols_no_ranges]
  end
end
