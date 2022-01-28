# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Framers::Table do
  let(:service) { described_class.new(frame: Rover::DataFrame.new(frame_data)) }

  describe "#perform" do
    let(:frame_data) do
      [
        { "header" => "a", "value" => 1, "sheet_name" => "Sheet1", "row" => 1, "column" => "A" },
        { "header" => "a", "value" => 2, "sheet_name" => "Sheet1", "row" => 2, "column" => "A" },
        { "header" => "a", "value" => 3, "sheet_name" => "Sheet1", "row" => 3, "column" => "A" },
        { "header" => "b", "value" => 10, "sheet_name" => "Sheet1", "row" => 1, "column" => "B" },
        { "header" => "b", "value" => 11, "sheet_name" => "Sheet1", "row" => 2, "column" => "B" },
        { "header" => "b", "value" => 12, "sheet_name" => "Sheet1", "row" => 3, "column" => "B" },
        { "header" => "organization_id", "value" => "aaa-bbb-ccc-ddd", "sheet_name" => "Sheet1", "row" => 0, "column" => "" }
      ]
    end
    let(:expected_results) do
      Rover::DataFrame.new([
        { "a" => 1, "b" => 10, "sheet_name" => "Sheet1", "organization_id" => "aaa-bbb-ccc-ddd", "row" => 1 },
        { "a" => 2, "b" => 11, "sheet_name" => "Sheet1", "organization_id" => "aaa-bbb-ccc-ddd", "row" => 2 },
        { "a" => 3, "b" => 12, "sheet_name" => "Sheet1", "organization_id" => "aaa-bbb-ccc-ddd", "row" => 3 }
      ])
    end

    it "returns a DataFrame of matrix values grouped into a table structure" do
      expect(service.perform).to eq(expected_results)
    end
  end
end
