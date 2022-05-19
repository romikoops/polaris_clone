# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::QueryType do
  include_context "V4 setup"

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
      "country_code" => "DE",
      "organization_id" => organization.id
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

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when distance based" do
      let(:identifier) { "distance" }
      let(:location) { nil }

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when location based postal_code and Locations::Location exist for the country" do
      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when locode based" do
      let(:identifier) { "locode" }
      let(:data_value) { "DEHAM" }

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when city based" do
      let(:identifier) { "city" }
      let(:data_value) { "Hamburg" }
      let(:example_row) { { identifier => "Hamburg", "province" => "Hamburg" } }

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when the identifier is invalid" do
      let(:identifier) { "blue" }
      let(:query_type) { :blue }

      it "returns the state with an error" do
        expect(result.errors.map(&:reason)).to include("The value 'BLUE' is not valid.")
      end
    end
  end
end
