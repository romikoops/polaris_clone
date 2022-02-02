# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Extractors::QueryType do
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
      "locations_location_id" => location&.id,
      "country_code" => "DE"
    }.merge(example_row)
  end
  let(:example_row) { { identifier => data_value } }
  let(:extracted_table) { result.frame }
  let(:identifier) { "postal_code" }
  let(:data_value) { "7795" }
  let(:location) do
    FactoryBot.create(:locations_location, name: data_value, country_code: "de")
  end
  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    context "when postal_code based but the country has no stored Locations::Locations" do
      let(:location) { nil }

      it "returns the frame with the QueryType 'postal_code'" do
        expect(extracted_table["query_type"].to_a).to include(described_class::QUERY_TYPE_ENUM["postal_code"])
      end
    end

    context "when distance based" do
      let(:identifier) { "distance" }
      let(:location) { nil }

      it "returns the frame with the location_id" do
        expect(extracted_table["query_type"].to_a).to include(described_class::QUERY_TYPE_ENUM["distance"])
      end
    end

    context "when location based postal_code and Locations::Location exist for the country" do

      it "returns the frame with the location_id" do
        expect(extracted_table["query_type"].to_a).to include(described_class::QUERY_TYPE_ENUM["location"])
      end
    end

    context "when locode based" do
      let(:identifier) { "locode" }
      let(:data_value) { "DEHAM" }

      it "returns the frame with the location_id" do
        expect(extracted_table["query_type"].to_a).to include(described_class::QUERY_TYPE_ENUM["location"])
      end
    end

    context "when city based" do
      let(:identifier) { "city" }
      let(:data_value) { "Hamburg" }
      let(:example_row) { { identifier => "Hamburg", "province" => "Hamburg" } }

      it "returns the frame with the location_id" do
        expect(extracted_table["query_type"].to_a).to include(described_class::QUERY_TYPE_ENUM["location"])
      end
    end
  end
end
