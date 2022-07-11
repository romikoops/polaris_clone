# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Operations::SacoImport do
  include_context "V4 setup"

  let(:operation_result) { described_class.state(state: state_arguments).frame }
  let(:rows) do
    test_groupings.map do |test_grouping|
      { "base" => 0,
        "service" => "standard",
        "carrier" => "Saco Shipping",
        "carrier_code" => "saco_shipping",
        "mode_of_transport" => "ocean",

        "fee_code" => "PRIMARY_FREIGHT_CODE",
        "effective_date" => Date.parse("Fri, 01 Apr 2022"),
        "expiration_date" => Date.parse("Sat, 30 Apr 2022"),
        "crl" => nil,
        "rate_info" => "New +",
        "group_id" => nil,
        "group_name" => nil,
        "cargo_class" => "lcl",
        "load_type" => "cargo_item",
        "range_min" => nil,
        "range_max" => nil,
        "period" => nil,

        "sheet_name" => "Tariff Sheet",
        "organization_id" => "be5994b6-20e5-4563-8c5f-174fbe233bea",
        "row" => 7 }.merge(test_grouping)
    end
  end
  let(:test_groupings) do
    [{
      "destination_locode" => "DEHAM",
      "origin_region" => "LATAM",
      "destination_region" => "EMEA",
      "origin_hub" => "Buenos Aires",
      "origin_locode" => "ARBUE",
      "currency" => "ARBUE",
      "minimum" => 218.0,
      "rate" => 218.0,
      "pre_carriage_minimum" => nil,
      "pre_carriage_rate" => nil,
      "pre_carriage_basis" => nil,
      "remarks" => "Surcharges",
      "transshipment" => nil,
      "transit_time" => "32.0",
      "Dynamic(Tariff Sheet-9):basis" => "W/M",
      "Dynamic(Tariff Sheet-14):basis" => "Incl. CAF/BAF/OHC"
    }, {
      "destination_locode" => "DEHAM",
      "origin_region" => "ASIA",
      "destination_region" => "EMEA",
      "origin_hub" => "Anqing",
      "origin_locode" => "CNAQG",
      "currency" => "CNAQG",
      "minimum" => 99.0,
      "rate" => 99.0,
      "pre_carriage_minimum" => 45.0,
      "pre_carriage_rate" => 45.0,
      "pre_carriage_basis" => "W/M",
      "remarks" => "Surcharges",
      "transshipment" => "Shanghai",
      "transit_time" => "36.0",
      "Dynamic(Tariff Sheet-9):basis" => "W/M",
      "Dynamic(Tariff Sheet-14):basis" => "Precarriage 333 kos = 1 cbm"
    }]
  end
  let(:types) do
    {
      "minimum" => :object,
      "rate" => :object,
      "pre_carriage_minimum" => :object,
      "pre_carriage_rate" => :object
    }
  end
  let(:pre_carriage_rows) { operation_result.filter("fee_code" => "pre_carriage") }

  describe "#perform" do
    it "takes the first of the the two 'basis' headers as `rate_basis`" do
      expect(operation_result["rate_basis"].to_a.uniq).to eq(["W/M"])
    end

    it "expands the included fees to rows with the included fee codes" do
      expect(operation_result.filter("rate" => 0)["fee_code"].to_a).to eq(%w[included_caf included_baf included_ohc])
    end

    it "converts the info from the pre carriage cells into their own rows" do
      expect(pre_carriage_rows.count).to eq(1)
    end

    it "converts secondary info related to pre-carriage cbm_ratio" do
      expect(pre_carriage_rows["cbm_ratio"].to_a).to eq([333.0])
    end
  end
end
