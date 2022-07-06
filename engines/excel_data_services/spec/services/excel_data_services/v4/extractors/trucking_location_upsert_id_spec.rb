# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::TruckingLocationUpsertId do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments, target_frame: "zones") }
  let(:address) { FactoryBot.build(:legacy_address, country: country) }
  let(:zones_rows) do
    [{
      "trucking_location_name" => trucking_location.data,
      "query_type" => Trucking::Location.queries[trucking_location.query],
      "country_id" => country.id,
      "organization_id" => organization.id
    }]
  end
  let(:extracted_table) { result.frame("zones") }
  let(:country) { FactoryBot.create(:legacy_country) }
  let!(:trucking_location) { FactoryBot.create(:trucking_location, country: country) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    it "returns the same value the model generates" do
      expect(extracted_table["upsert_id"].to_a).to eq([trucking_location.upsert_id])
    end
  end
end
