# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Operations::ExpandedDates do
  include_context "V4 setup"

  let(:extracted_table) { described_class.state(state: state_arguments).frame }
  let(:rows) do
    validities_with_fee_codes.map do |validity_and_fee_code|
      base_row.merge(validity_and_fee_code)
    end
  end
  let(:base_row) do
    { "service" => "standard",
      "row" => 3,
      "sheet_name" => "Sheet2",
      "group_id" => nil,
      "group_name" => nil,
      "origin_locode" => "SEGOT",
      "origin" => "Gothenburg",
      "origin_country" => "Sweden",
      "destination_locode" => "CNSHA",
      "destination" => "Shanghai",
      "destination_country" => "China",
      "mode_of_transport" => "ocean",
      "carrier" => "msc",
      "service_level" => "standard",
      "cargo_class" => "fcl_20",
      "internal" => nil,
      "transshipment" => nil,
      "fee_name" => nil,
      "fee_code" => nil,
      "rate" => nil,
      "rate_basis" => "PER_CONTAINER",
      "range_min" => nil,
      "range_max" => nil,
      "base" => nil,
      "origin_terminal" => nil,
      "destination_terminal" => nil,
      "organization_id" => organization.id }
  end
  let(:fee_codes) { ["bas"] }

  describe "#data" do
    context "with no conflicts" do
      let(:validities_with_fee_codes) do
        [
          { "effective_date" => Date.parse("Tue, 29 Dec 2020"), "expiration_date" => Date.parse("Fri, 31 Dec 2021"), "fee_code" => "bas" }
        ]
      end

      it "returns the frame untouched" do
        expect(extracted_table.to_a).to match_array(rows)
      end
    end

    context "with no conflicts (sequential)" do
      let(:validities_with_fee_codes) do
        [
          { "effective_date" => Date.parse("29 Dec 2020"), "expiration_date" => Date.parse("31 Dec 2021"), "fee_code" => "bas" },
          { "effective_date" => Date.parse("1 Jan 2021"), "expiration_date" => Date.parse("31 Dec 2022"), "fee_code" => "bas" },
          { "effective_date" => Date.parse("29 Dec 2020"), "expiration_date" => Date.parse("31 Dec 2022"), "fee_code" => "baf" }
        ]
      end
      let(:expected_dates) do
        [
          { "effective_date" => Date.parse("29 Dec 2020"), "expiration_date" => Date.parse("31 Dec 2020") },
          { "effective_date" => Date.parse("1 Jan 2021"), "expiration_date" => Date.parse("31 Dec 2021") },
          { "effective_date" => Date.parse("1 Jan 2022"), "expiration_date" => Date.parse("31 Dec 2022") }
        ]
      end

      it "returns the frame with the baf fee split for the three periods" do
        expect(extracted_table[extracted_table["fee_code"] == "baf"][%w[effective_date expiration_date]].to_a.uniq).to match_array(
          expected_dates
        )
      end
    end
  end
end
