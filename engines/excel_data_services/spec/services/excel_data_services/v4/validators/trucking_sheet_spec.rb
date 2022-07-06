# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::TruckingSheet do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments, target_frame: "rates") }
  let(:extracted_table) { result.frame("rates") }
  let(:rates_rows) do
    test_groupings.map do |test_grouping|
      {
        "row" => 6,
        "zone" => "1.0",
        "modifier" => "kg",
        "organization_id" => organization.id,
        "sheet_name" => "Sheet1",
        "range_min" => 0,
        "range_max" => 100.0
      }.merge(test_grouping)
    end
  end
  let(:zones_rows) do
    [{
      "row" => 2,
      "zone" => "1.0",
      "identifier" => "postal_code",
      "postal_code" => "20457",
      "organization_id" => organization.id,
      "sheet_name" => "Zones"
    }]
  end
  let(:rows) do
    [{
      "row" => 2,
      "service" => "standard",
      "carrier" => "Test Carrier",
      "carrier_code" => "test carrier",
      "direction" => "export",
      "cargo_class" => "lcl",
      "load_type" => "cargo_item",
      "rate_type" => "trucking_rate",
      "truck_type" => "default",
      "effective_date" => Date.parse("Tue, 01 Sep 2020"),
      "expiration_date" => expiration_date,
      "cbm_ratio" => 250.0,
      "organization_id" => organization.id,
      "sheet_name" => "Sheet1"
    }]
  end
  let(:expiration_date) { Date.parse("Fri, 31 Dec 2021") }

  before { Timecop.freeze(Date.parse("2020/01/01")) }

  after { Timecop.return }

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

    context "when there is an overlap in the weight brackets" do
      let(:test_groupings) do
        [
          { "range_min" => 0, "range_max" => 12 },
          { "range_min" => 11, "range_max" => 20 }
        ]
      end

      let(:error_messages) do
        [
          "Ranges cannot overlap. Ranges on sheet 'Sheet1' are conflicting"
        ]
      end

      it "returns the state with the range overlap message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when there is no space in the weight brackets" do
      let(:test_groupings) do
        [
          { "range_min" => 10, "range_max" => 10 }
        ]
      end

      let(:error_messages) do
        [
          "Ranges cannot be empty. Sheet contains the empty range: '10 - 10'."
        ]
      end

      it "returns the state with the empty range message" do
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
      let(:zones_rows) do
        [
          { "zone" => "1.0", "postal_code" => "20457", "row" => 2, "identifier" => "postal_code" },
          { "zone" => "2.0", "postal_code" => "20457", "row" => 3, "identifier" => "postal_code" }
        ]
      end
      let(:test_groupings) { [{}] }

      let(:error_messages) { ["Places cannot exist in multiple zones. 20457 is defined in mulitple zones (1.0, 2.0). Please remove all but one."] }

      it "returns the state with the missing RANGE_MIN error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when the range is invalid" do
      let(:test_groupings) { [{}] }
      let(:zones_rows) do
        [
          { "zone" => "1.0", "postal_code" => "20457", "row" => 2, "range" => "9999 - 1111", "identifier" => "postal_code" }
        ]
      end

      let(:error_messages) { ["Invalid Range: Ranges are defined from lower bound to upper bound."] }

      it "returns the state with the invalid range error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end

    context "when the expiration_date is in the past" do
      let(:test_groupings) { [{}] }
      let(:expiration_date) { Date.parse("Tue, 01 Sep 2019") }
      let(:error_messages) { ["Already expired rates are not permitted."] }

      it "returns the state with the invalid range error message" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
