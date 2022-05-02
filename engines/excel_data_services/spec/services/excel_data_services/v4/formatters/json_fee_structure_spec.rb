# frozen_string_literal: false

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Formatters::JsonFeeStructure do
  let(:service) { described_class.new(frame: frame) }

  describe "#perform" do
    shared_examples_for "a successful formatting" do
      it "returns the correctly formatted data" do
        expect(service.perform).to eq(expected_fees)
      end
    end

    context "when the rates are Legacy::LocalCharge" do
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
      let(:frame) { Rover::DataFrame.new(row_deltas.map { |delta| base_row.merge(delta) }) }

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
            {
              "base" => nil,
              "min" => 2.0,
              "max" => 100.0,
              "ton" => 4.0,
              "rate_basis" => "PER_TON",
              "currency" => "EUR",
              "range" => [],
              "name" => "B/L Fee",
              "key" => "BL"
            } }
        end

        it_behaves_like "a successful formatting"
      end

      context "with a range based fee" do
        let(:row_deltas) do
          [
            {
              "fee_code" => "bl",
              "fee_name" => "B/L Fee",
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
            {
              "base" => nil,
              "min" => 2.0,
              "max" => 100.0,
              "rate_basis" => "PER_KG",
              "currency" => "EUR",
              "range" => [{ "min" => 0.0, "max" => 100.0, "kg" => 4.0 }],
              "name" => "B/L Fee",
              "key" => "BL"
            } }
        end

        it_behaves_like "a successful formatting"
      end

      context "with a range based fee stowage fee" do
        let(:row_deltas) do
          [
            {
              "fee_code" => "stw",
              "fee_name" => "Stowage",
              "external_code" => "PER_UNIT_TON_CBM_RANGE",
              "row" => 2,
              "min" => 2.0,
              "max" => 100.0,
              "currency" => "EUR",
              "rate_basis" => "PER_UNIT_TON_CBM_RANGE",
              "cbm" => 8.0,
              "range_min" => 0.0,
              "range_max" => 10.0
            },
            {
              "fee_code" => "stw",
              "fee_name" => "Stowage",
              "external_code" => "PER_UNIT_TON_CBM_RANGE",
              "row" => 2,
              "min" => 2.0,
              "max" => 100.0,
              "currency" => "EUR",
              "rate_basis" => "PER_UNIT_TON_CBM_RANGE",
              "ton" => 4.0,
              "range_min" => 10.0,
              "range_max" => 100.0
            }
          ]
        end

        let(:expected_fees) do
          { "STW" =>
            {
              "base" => nil,
              "currency" => "EUR",
              "key" => "STW",
              "max" => 100.0,
              "min" => 2.0,
              "rate_basis" => "PER_UNIT_TON_CBM_RANGE",
              "range" => [{ "min" => 0.0, "max" => 10.0, "cbm" => 8.0 }, { "min" => 10.0, "max" => 100.0, "ton" => 4.0 }],
              "name" => "Stowage"
            } }
        end

        it_behaves_like "a successful formatting"
      end

      context "when the sheet style is Trucking" do
        let(:frame) { FactoryBot.build(:excel_data_services_section_data, :trucking).filter({ "rate_type" => "trucking_fee" }) }
        let(:expected_fees) do
          { "FSC" =>
            {
              "base" => nil,
              "min" => nil,
              "max" => nil,
              "rate_basis" => "PER_SHIPMENT",
              "currency" => "EUR",
              "name" => "Fuel Surcharge Fee",
              "shipment" => 30.0,
              "key" => "FSC",
              "range" => []
            } }
        end

        it_behaves_like "a successful formatting"
      end
    end
  end
end
