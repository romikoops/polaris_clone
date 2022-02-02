# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Extractors::QueryMethod do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:row) do
    {
      "postal_code" => nil,
      "city" => nil,
      "locode" => nil,
      "distance" => nil,
      "zone" => 1.0,
      "identifier" => identifier,
      "country_code" => "DE",
      "query_type" => ExcelDataServices::V3::Extractors::QueryType::QUERY_TYPE_ENUM[query_type]
    }
  end
  let(:query_type) { :postal_code }
  let(:extracted_table) { result.frame }
  let(:identifier) { "postal_code" }

  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    context "when postal_code based but the country has no stored Locations::Locations" do
      it "returns the frame with the QueryMethod 'postal_code'" do
        expect(extracted_table["query_method"].to_a).to include(described_class::QUERY_METHOD_ENUM["zipcode"])
      end
    end

    context "when distance based" do
      let(:identifier) { "distance" }
      let(:query_type) { :distance }

      it "returns the frame with the location_id" do
        expect(extracted_table["query_method"].to_a).to include(described_class::QUERY_METHOD_ENUM["distance"])
      end
    end

    context "when location based postal_code and Locations::Location exist for the country" do
      let(:query_type) { :location }

      it "returns the frame with the location_id" do
        expect(extracted_table["query_method"].to_a).to include(described_class::QUERY_METHOD_ENUM["location"])
      end
    end

    context "when locode based" do
      let(:identifier) { "locode" }
      let(:data_value) { "DEHAM" }
      let(:query_type) { :location }

      it "returns the frame with the location_id" do
        expect(extracted_table["query_method"].to_a).to include(described_class::QUERY_METHOD_ENUM["location"])
      end
    end

    context "when city based" do
      let(:identifier) { "city" }
      let(:data_value) { "Hamburg" }
      let(:query_type) { :location }
      let(:example_row) { { identifier => "Hamburg", "province" => "Hamburg" } }

      it "returns the frame with the location_id" do
        expect(extracted_table["query_method"].to_a).to include(described_class::QUERY_METHOD_ENUM["location"])
      end
    end
  end
end
