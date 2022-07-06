# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::TruckingLocation do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:address) { FactoryBot.build(:legacy_address, country: country) }
  let(:row) do
    {
      "postal_code" => nil,
      "city" => nil,
      "locode" => nil,
      "distance" => nil,
      "zone" => 1.0,
      "identifier" => identifier,
      "locations_location_id" => location&.id,
      "country_id" => country.id,
      "country_code" => country.code,
      "query_type" => ExcelDataServices::V4::Extractors::QueryType::QUERY_TYPE_ENUM[query_type],
      "organization_id" => organization.id,
      "trucking_location_name" => data_value
    }.merge(example_row)
  end
  let(:example_row) { { identifier => data_value } }
  let(:extracted_table) { result.frame }
  let(:identifier) { "postal_code" }
  let(:query_type) { :postal_code }
  let(:data_value) { "7795" }
  let(:country) { FactoryBot.create(:legacy_country) }
  let(:location) do
    FactoryBot.create(:locations_location, name: data_value, country_code: country.code.downcase)
  end

  before do
    FactoryBot.create(:trucking_location,
      data: data_value,
      query: query_type,
      location: location,
      country: country)
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    context "when string based zipcode" do
      let(:location) { nil }

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when distance based" do
      let(:identifier) { "distance" }
      let(:query_type) { :distance }
      let(:location) { nil }

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when location based postal_code" do
      let(:query_type) { :location }

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when locode based" do
      let(:query_type) { :location }
      let(:identifier) { "locode" }
      let(:data_value) { "DEHAM" }

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when city based" do
      let(:query_type) { :location }
      let(:identifier) { "city" }
      let(:data_value) { "Hamburg" }
      let(:example_row) { { identifier => "Hamburg", "province" => "Hamburg" } }

      it "returns the state with no errors" do
        expect(result.errors).to be_empty
      end
    end

    context "when the Trucking Location is not found" do
      let(:example_row) { { "trucking_location_name" => "xxx", identifier => "xxx" } }

      it "returns an error" do
        expect(result.errors.map(&:reason)).to include("The location 'xxx, (#{country.code})' cannot be found.")
      end
    end
  end
end
