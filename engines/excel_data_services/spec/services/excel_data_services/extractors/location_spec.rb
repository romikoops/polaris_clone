# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Extractors::Location do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:extracted_table) { result.frame }
  let(:frame) { Rover::DataFrame.new([row]) }
  let(:data_value) { row["primary"] }
  let(:query_type) { :postal_code }
  let(:country) { FactoryBot.create(:legacy_country, code: row["country_code"]) }
  let(:location) { nil }
  let!(:trucking_location) do
    FactoryBot.create(:trucking_location,
      data: data_value,
      query: query_type,
      country: country)
  end

  before do
    Organizations.current_id = organization.id
  end

  describe ".data" do
    context "when string based zipcode" do
      let(:row) { { zone: 1.0, identifier: "zipcode", primary: "7795", country_code: "ZA" }.stringify_keys }

      it "returns the frame with the location_id and inserts Trucking::Locations" do
        expect(extracted_table["location_id"].to_a).to match_array([trucking_location.id])
      end
    end

    context "when distance based" do
      let(:data_value) { row["primary"] }
      let(:query_type) { :distance }
      let(:row) { { zone: 1.0, identifier: "distance", primary: "75", country_code: "ZA" }.stringify_keys }

      it "returns the frame with the location_id and inserts Trucking::Locations" do
        expect(extracted_table["location_id"].to_a).to match_array([trucking_location.id])
      end
    end

    context "when location based postal_code" do
      let(:query_type) { :location }
      let(:row) { { zone: 1.0, identifier: "postal_code", primary: "20457", country_code: "DE" }.stringify_keys }

      it "returns the frame with the location_id and inserts Trucking::Locations" do
        expect(extracted_table["location_id"].to_a).to match_array([trucking_location.id])
      end
    end

    context "when locode based" do
      let(:query_type) { :location }
      let(:row) { { zone: 1.0, identifier: "locode", primary: "DEHAM", country_code: "DE" }.stringify_keys }

      it "returns the frame with the location_id and inserts Trucking::Locations" do
        expect(extracted_table["location_id"].to_a).to include(trucking_location.id)
      end
    end
  end
end
