# frozen_string_literal: false

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Formatters::LocalCharge do
  include_context "for excel_data_services setup"

  describe "#insertable_data" do
    let(:rows) do
      [{ "counterpart_terminal" => nil,
         "counterpart_locode" => nil,
         "counterpart_country" => nil,
         "counterpart_hub" => nil,
         "mode_of_transport" => "ocean",
         "counterpart_hub_id" => nil,
         "terminal" => nil,
         "locode" => "DEHAM",
         "country" => "Germany",
         "hub" => "Hamburg",
         "hub_id" => 3554,
         "charge_category_id" => 944,
         "fee_code" => "bl",
         "fee_name" => "B/L Fee",
         "tenant_vehicle_id" => 1012,
         "carrier_id" => 961,
         "carrier" => "SSC",
         "rate_basis_id" => "74e8dcfc-a47c-462a-aefe-108f696a24c0",
         "external_code" => "PER_TON",
         "join_value" => nil,
         "routing_carrier_id" => nil,
         "carrier_code" => "ssc",
         "row" => 2,
         "sheet_name" => "Local Charges",
         "service" => "standard",
         "group_id" => "33729e95-ca5e-44b4-b387-d45499afb9ed",
         "group_name" => "Local Charges Group One",
         "effective_date" => Date.parse("Sat, 01 May 2021"),
         "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
         "direction" => "export",
         "service_level" => "standard",
         "cargo_class" => "lcl",
         "load_type" => "lcl",
         "min" => nil,
         "max" => nil,
         "currency" => "EUR",
         "rate_basis" => "PER_TON",
         "range_min" => nil,
         "range_max" => nil,
         "base" => nil,
         "ton" => 0.4e1,
         "cbm" => nil,
         "kg" => nil,
         "item" => nil,
         "shipment" => nil,
         "bill" => nil,
         "container" => nil,
         "wm" => nil,
         "percentage" => nil,
         "dangerous" => nil,
         "internal" => nil,
         "organization_id" => "5a72a4d8-b836-441b-bb8a-0bf590db7db9" }]
    end
    let(:expected_data) do
      [{ "effective_date" => Date.parse("Sat, 01 May 2021"),
         "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
         "hub_id" => 3554,
         "counterpart_hub_id" => nil,
         "group_id" => "33729e95-ca5e-44b4-b387-d45499afb9ed",
         "tenant_vehicle_id" => 1012,
         "organization_id" => "5a72a4d8-b836-441b-bb8a-0bf590db7db9",
         "dangerous" => nil,
         "internal" => nil,
         "metadata" =>
         { "sheet_name" => "Local Charges",
           "row_number" => "2",
           "file_name" => "test-sheet.xlsx",
           "document_id" => file.id },
         "fees" =>
         { "BL" =>
           { "organization_id" => "5a72a4d8-b836-441b-bb8a-0bf590db7db9",
             "base" => nil,
             "min" => nil,
             "max" => nil,
             "charge_category_id" => 944,
             "rate_basis_id" => "74e8dcfc-a47c-462a-aefe-108f696a24c0",
             "currency" => "EUR",
             "range" => [],
             "metadata" =>
             { "sheet_name" => "Local Charges",
               "row_number" => "2",
               "file_name" => "test-sheet.xlsx",
               "document_id" => file.id } } },
         "load_type" => "lcl",
         "validity" => "[2021-05-01, 2021-12-31)",
         "uuid" => "fd3b22f4-3fd7-584b-b5c7-255b754d3956" }]
    end

    let(:service) { described_class.state(state: state_arguments) }

    it "returns the formatted data" do
      expect(service.insertable_data).to match_array(expected_data)
    end
  end
end
