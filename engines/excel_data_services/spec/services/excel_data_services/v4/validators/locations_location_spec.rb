# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::LocationsLocation do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments, target_frame: "zones") }
  let(:base_row) do
    {
      "locations_location_id" => nil,
      "postal_code" => nil,
      "city" => nil,
      "locode" => nil,
      "distance" => nil,
      "zone" => 1.0,
      "row" => 2,
      "identifier" => identifier,
      "query_type" => ExcelDataServices::V4::Extractors::QueryType::QUERY_TYPE_ENUM[query_type],
      "organization_id" => organization.id
    }
  end
  let(:extracted_table) { result.frame("zones") }
  let(:frames) { { "zones" => frame } }
  let(:identifier) { "postal_code" }
  let(:query_type) { :postal_code }
  let(:mocked_extracted_frame) do
    frame.tap do |tapped_frame|
      tapped_frame["locations_location_id"] = [nil] * tapped_frame.count
    end
  end
  let(:mocked_extracted_state) do
    state_arguments.tap do |tapped_state|
      tapped_state.set_frame(value: mocked_extracted_frame, key: "zones")
    end
  end

  before do
    mocked_extractor = instance_double(ExcelDataServices::V4::Extractors::LocationsLocation, perform: mocked_extracted_state)
    allow(ExcelDataServices::V4::Extractors::LocationsLocation).to receive(:new).and_return(mocked_extractor)
  end

  describe "#perform" do
    context "when string based zipcode with no location_id" do
      let(:location) { nil }
      let(:row) { base_row.merge({ identifier => "7795", "country_code" => "ZA" }) }

      it "returns no warnings as the Query Type doesnt need a location id" do
        expect(result.warnings).to be_empty
      end
    end

    context "when distance based with no location_id" do
      let(:identifier) { "distance" }
      let(:query_type) { :distance }
      let(:location) { nil }
      let(:row) { base_row.merge({ identifier => "75", "country_code" => "ZA" }) }

      it "returns no location id as the Query Type doesnt need one" do
        expect(result.warnings).to be_empty
      end
    end

    context "when location based postal_code" do
      let(:query_type) { :location }
      let(:row) { base_row.merge({ identifier => "20457", "country_code" => "DE" }) }

      it "returns an error detailing what could not be found" do
        expect(result.warnings.map(&:reason)).to include("The location '20457, DE' cannot be found.")
      end
    end

    context "when locode based" do
      let(:query_type) { :location }
      let(:identifier) { "locode" }
      let(:row) { base_row.merge({ identifier => "DEHAM", "country_code" => "DE" }) }

      it "returns the frame with the location_id" do
        expect(result.warnings.map(&:reason)).to include("The location 'DEHAM, DE' cannot be found.")
      end
    end

    context "when city based" do
      let(:query_type) { :location }
      let(:identifier) { "city" }
      let(:row) { base_row.merge({ identifier => "Hamburg", "province" => "Hamburg", "country_code" => "DE" }) }

      it "returns the frame with the location_id" do
        expect(result.warnings.map(&:reason)).to include("The location 'Hamburg, Hamburg, DE' cannot be found.")
      end
    end

    context "when postal_city based" do
      let(:query_type) { :location }
      let(:identifier) { "postal_city" }
      let(:row) { base_row.merge({ "postal_code" => "20457", "city" => "Hamburg", "country_code" => "DE" }) }

      it "returns the frame with the location_id" do
        expect(result.warnings.map(&:reason)).to include("The location '20457, Hamburg, DE' cannot be found.")
      end
    end
  end
end
