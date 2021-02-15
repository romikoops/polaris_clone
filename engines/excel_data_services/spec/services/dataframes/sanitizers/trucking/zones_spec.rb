# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Sanitizers::Trucking::Zones do
  let(:frame_data) do
    {"zone" => "1.0 ",
     "primary_postal_code" => "210001 ",
     "primary_locode" => "DEHAM ",
     "primary_city" => "Shanghai ",
     "primary_distance" => "100.0 ",
     "secondary_postal_code" => "20000 - 21599 ",
     "country_code" => "de"}
  end
  let(:expected_results) do
    {"zone" => "1.0",
     "primary_postal_code" => "210001",
     "primary_locode" => "DEHAM",
     "primary_city" => "Shanghai",
     "primary_distance" => "100.0",
     "secondary_postal_code" => "20000 - 21599",
     "country_code" => "DE"}
  end

  describe ".sanitize" do
    it "sanitizes each value correctly", :aggregate_failures do
      frame_data.each do |attribute, value|
        sanitized_value = described_class.sanitize(value: value, attribute: attribute)
        expect(sanitized_value).to eq(expected_results[attribute])
      end
    end
  end
end
