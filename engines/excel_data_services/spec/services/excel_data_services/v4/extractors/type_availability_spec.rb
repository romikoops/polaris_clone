# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::TypeAvailability do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:country) { FactoryBot.create(:legacy_country) }
  let!(:trucking_type_availability) { FactoryBot.create(:trucking_type_availability, :distance, country: country) }
  let(:query_method) { ExcelDataServices::V4::Extractors::QueryMethod::QUERY_METHOD_ENUM["distance"] }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "truck_type" => "default",
          "load_type" => "cargo_item",
          "carriage" => "pre",
          "country_code" => country.code,
          "query_method" => query_method,
          "row" => 2
        }
      end

      it "returns the frame with the type_availability_id" do
        expect(extracted_table["type_availability_id"].to_a).to eq([trucking_type_availability.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "truck_type" => "default",
          "load_type" => "cargo_item",
          "carriage" => "on",
          "country_code" => "FR",
          "query_method" => query_method,
          "row" => 2
        }
      end

      it "does not find the record or add a type_availability_id" do
        expect(extracted_table["type_availability_id"].to_a).to eq([nil])
      end
    end
  end
end
