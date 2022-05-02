# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::TypeAvailability do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:country) { FactoryBot.create(:legacy_country) }
  let(:query_method) { ExcelDataServices::V4::Extractors::QueryMethod::QUERY_METHOD_ENUM["distance"] }

  describe ".state" do
    context "when found" do
      before { FactoryBot.create(:trucking_type_availability, :distance, country: country) }

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

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
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

      it "returns an error detailing what is invalid" do
        expect(extracted_table["type_availability_id"].to_a).to eq([nil])
      end
    end
  end
end
