# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Helpers::PrefixedColumnMapper do
  let(:input_frame) { Rover::DataFrame.new(input_data) }
  let(:input_data) do
    [
      { "value" => "postal_code", "header" => header, "row" => 1, "column" => "B", "sheet_name" => "Zones" }
    ]
  end
  let(:header) { "identifier" }

  describe "#frame" do
    let(:result_frame) { described_class.new(mapped_object: input_frame.dup, header: header).perform }

    it "returns a DataFrame with the value under the header" do
      expect(result_frame[header]).to eq(input_frame["value"])
    end

    it "returns a DataFrame with the row and column keys prefixed with the header", :aggregate_failures do
      expect(result_frame["#{header}_row"]).to eq(input_frame["row"])
      expect(result_frame["#{header}_column"]).to eq(input_frame["column"])
    end
  end
end
