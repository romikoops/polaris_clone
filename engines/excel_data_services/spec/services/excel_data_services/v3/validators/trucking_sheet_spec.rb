# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Validators::TruckingSheet do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:rows) do
    test_groupings.map do |test_grouping|
      {
        "zone_row" => 6,
        "zone" => "1.0",
        "postal_code" => "20457",
        "country_code" => "DE",
        "service" => "standard",
        "carrier" => "Test Carrier",
        "carrier_code" => "test carrier",
        "direction" => "export",
        "cargo_class" => "lcl",
        "load_type" => "cargo_item",
        "rate_type" => "trucking_rate",
        "truck_type" => "default",
        "effective_date" => Date.parse("Tue, 01 Sep 2020"),
        "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
        "cbm_ratio" => 250.0,
        "modifier" => "kg",
        "organization_id" => organization.id,
        "identifier" => "postal_code",
        "sheet_name" => "Sheet1"
      }.merge(test_grouping)
    end
  end

  describe ".state" do
    context "when there is a gap in the weight brackets" do
      let(:test_groupings) do
        [
          { "range_min" => 0, "range_max" => 10 },
          { "range_min" => 11, "range_max" => 20 }
        ]
      end

      let(:error_messages) do
        [
          "All ranges are exclusive. This means the last value of the range is ignored. Please ensure the next range starts with the same value the previous range ended with to ensure coverage."
        ]
      end

      it "returns the state with the range gap message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when the sheet is missing a modifier" do
      let(:test_groupings) do
        [
          { "modifier" => nil }
        ]
      end

      let(:error_messages) { ["All rate Columns need a modifier to be defined in row 4."] }

      it "returns the state with the missing modifier error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when the target location has been assigned to more than one zone" do
      let(:test_groupings) do
        [
          { "zone" => "1.0", "postal_code" => "20457" },
          { "zone" => "2.0", "postal_code" => "20457", "zone_row" => 7 }
        ]
      end

      let(:error_messages) { ["Places cannot exist in multiple zones. 20457 is defined in mulitple zones (1.0, 2.0). Please remove all but one."] }

      it "returns the state with the missing RANGE_MIN error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
