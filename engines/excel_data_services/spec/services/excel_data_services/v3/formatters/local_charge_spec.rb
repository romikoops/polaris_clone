# frozen_string_literal: false

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Formatters::LocalCharge do
  include_context "V3 setup"

  let(:service) { described_class.state(state: state_arguments) }

  describe "#insertable_data" do
    let(:base_row) do
      { "counterpart_terminal" => nil,
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
        "tenant_vehicle_id" => 1012,
        "carrier_id" => 961,
        "carrier" => "SSC",
        "join_value" => nil,
        "routing_carrier_id" => nil,
        "carrier_code" => "ssc",
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
        "range_min" => nil,
        "range_max" => nil,
        "base" => nil,
        "ton" => nil,
        "cbm" => nil,
        "kg" => nil,
        "item" => nil,
        "shipment" => nil,
        "bill" => nil,
        "container" => nil,
        "wm" => nil,
        "percentage" => nil,
        "dangerous" => false,
        "internal" => false,
        "organization_id" => "5a72a4d8-b836-441b-bb8a-0bf590db7db9" }
    end
    let(:rows) { row_deltas.map { |delta| base_row.merge(delta) } }
    let(:expected_data) do
      [{ "effective_date" => Date.parse("Sat, 01 May 2021"),
         "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
         "hub_id" => 3554,
         "direction" => "export",
         "mode_of_transport" => "ocean",
         "counterpart_hub_id" => nil,
         "group_id" => "33729e95-ca5e-44b4-b387-d45499afb9ed",
         "tenant_vehicle_id" => 1012,
         "organization_id" => "5a72a4d8-b836-441b-bb8a-0bf590db7db9",
         "dangerous" => false,
         "internal" => false,
         "metadata" =>
         { "sheet_name" => "Local Charges",
           "row_number" => "2",
           "file_name" => "test-sheet.xlsx",
           "document_id" => file.id },
         "fees" => expected_fees,
         "load_type" => "lcl",
         "validity" => "[2021-05-01, 2021-12-31)",
         "uuid" => "9bbe7239-c9f6-55be-9287-6ef47a4d7b0c" }]
    end

    context "with a non range based fee" do
      let(:row_deltas) do
        [
          {
            "charge_category_id" => 944,
            "fee_code" => "bl",
            "fee_name" => "B/L Fee",
            "rate_basis_id" => "74e8dcfc-a47c-462a-aefe-108f696a24c0",
            "external_code" => "PER_TON",
            "row" => 2,
            "min" => 2.0,
            "max" => 100.0,
            "currency" => "EUR",
            "rate_basis" => "PER_TON",
            "ton" => 4.0
          }
        ]
      end
      let(:expected_fees) do
        { "BL" =>
          { "organization_id" => "5a72a4d8-b836-441b-bb8a-0bf590db7db9",
            "base" => nil,
            "min" => 2.0,
            "max" => 100.0,
            "ton" => 0.4e1,
            "charge_category_id" => 944,
            "rate_basis_id" => "74e8dcfc-a47c-462a-aefe-108f696a24c0",
            "rate_basis" => "PER_TON",
            "currency" => "EUR",
            "range" => [],
            "name" => "B/L Fee",
            "code" => "BL" } }
      end

      let(:types) do
        {
          "counterpart_hub_id" => :object,
          "dangerous" => :object,
          "internal" => :object
        }
      end

      it "returns the formatted data" do
        expect(service.insertable_data).to match_array(expected_data)
      end
    end

    context "with a range based fee" do
      let(:row_deltas) do
        [
          {
            "charge_category_id" => 944,
            "fee_code" => "bl",
            "fee_name" => "B/L Fee",
            "rate_basis_id" => "74e8dcfc-a47c-462a-aefe-108f696a24c0",
            "external_code" => "PER_KG",
            "row" => 2,
            "min" => 2.0,
            "max" => 100.0,
            "currency" => "EUR",
            "rate_basis" => "PER_KG",
            "kg" => 4.0,
            "range_min" => 0.0,
            "range_max" => 100.0
          }
        ]
      end

      let(:expected_fees) do
        { "BL" =>
          { "organization_id" => "5a72a4d8-b836-441b-bb8a-0bf590db7db9",
            "base" => nil,
            "min" => 2.0,
            "max" => 100.0,
            "kg" => 0.4e1,
            "charge_category_id" => 944,
            "rate_basis_id" => "74e8dcfc-a47c-462a-aefe-108f696a24c0",
            "rate_basis" => "PER_KG",
            "currency" => "EUR",
            "range" => [{ "min" => 0.0, "max" => 100.0, "kg" => 4.0 }],
            "name" => "B/L Fee",
            "code" => "BL" } }
      end

      let(:types) do
        {
          "counterpart_hub_id" => :object,
          "dangerous" => :object,
          "internal" => :object
        }
      end

      it "returns the formatted data" do
        expect(service.insertable_data).to match_array(expected_data)
      end
    end
  end
end
