# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Operations::Grdb do
  include_context "V4 setup"

  let(:extracted_table) { described_class.state(state: state_arguments).frame }
  let(:base_row) do
    { "service" => "standard",
      "carrier" => "WWA",
      "carrier_code" => "wwa",
      "customer" => "P.E.T. MÜLHEIM",
      "wwa_member" => "SSLL",
      "origin_region" => "EMEA",
      "origin_inland_cfs" => "DEHAM",
      "consol_cfs" => "DEHAM",
      "origin_locode" => "DEHAM",
      "transhipment_1" => "NLRTM",
      "transhipment_2" => "EGEDK",
      "transhipment_3" => "JOAQJ",
      "destination_region" => "EMEA",
      "destination_locode" => "JOAMM",
      "deconsol_cfs" => "JOAMM",
      "destination_inland_cfs" => nil,
      "quoting_region" => "EMEA",
      "group_id" => nil,
      "group_name" => nil,
      "cargo_class" => "lcl",
      "load_type" => "cargo_item",
      "mode_of_transport" => "ocean",
      "internal" => false,
      "range_min" => nil,
      "range_max" => nil,
      "base" => nil,
      "sheet_name" => "P.E.T. MÜLHEIM_027025_GRDB_Ex",
      "row" => 2,
      "currency" => nil,
      "rate_basis" => nil,
      "minimum" => 10.0,
      "maximum" => 1000.0,
      "notes" => nil,
      "effective_date" => nil,
      "expiration_date" => nil,
      "rate" => nil,
      "from" => nil,
      "to" => nil,
      "organization_id" => "50d62577-b294-47f0-b32b-bd696366eb9b" }
  end

  describe "#data" do
    let(:rows) do
      fee_versions.map do |fee_version|
        base_row.merge(fee_version)
      end
    end
    let(:fee_versions) do
      [
        { "fee_code" => "ocean_freight", "fee_name" => "Ocean Freight", "rate" => 100.0 },
        { "fee_code" => "container_loading", "fee_name" => "Container Loading", "rate" => 50.0 }
      ]
    end

    it "returns a frame with transshipments joined together" do
      expect(extracted_table["transshipment"].to_a).to eq([rows.first.values_at("transhipment_1", "transhipment_2", "transhipment_3").join("_")] * 2)
    end

    it "returns a frame with minimum, maximum and notes renamed to min, max and remarks respectively", :aggregate_failures do
      expect(extracted_table["min"].to_a).to eq(rows.pluck("minimum"))
      expect(extracted_table["max"].to_a).to eq(rows.pluck("maximum"))
    end

    context "when the ocean_freight fee is on request" do
      let(:fee_versions) do
        [
          { "fee_code" => "ocean_freight", "fee_name" => "Ocean Freight", "rate" => "on request" },
          { "fee_code" => "container_loading", "fee_name" => "Container Loading", "rate" => 50.0 },
          { "fee_code" => "ocean_freight", "fee_name" => "Ocean Freight", "rate" => 125.0, "row" => 3 },
          { "fee_code" => "container_loading", "fee_name" => "Container Loading", "rate" => 75.0, "row" => 3 }
        ]
      end

      it "returns ignores all rows where the 'ocean_freight' fee is 'on request'" do
        expect(extracted_table["row"].to_a.uniq).to match_array([3])
      end
    end
  end
end
