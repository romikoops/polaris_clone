# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillTruckingLocationIdentifierWorker, type: :worker do
  let(:locations_location) { FactoryBot.create(:locations_location, osm_id: 2) }
  let!(:postal_code_string_location) { FactoryBot.create(:trucking_location, :postal_code, identifier: nil) }
  let!(:postal_code_location_location) { FactoryBot.create(:trucking_location, :postal_code_location, identifier: nil) }
  let!(:city_location_location) { FactoryBot.create(:trucking_location, :with_chinese_location, identifier: nil) }
  let!(:locode_location_location) { FactoryBot.create(:trucking_location, :locode_location, location: locations_location, identifier: nil) }
  let!(:distance_location) { FactoryBot.create(:trucking_location, :distance, identifier: nil) }

  before { described_class.new.perform }

  describe "#perform" do
    it "updates the location identifier", :aggregate_failures do
      expect(postal_code_string_location.reload.identifier).to eq("postal_code")
      expect(postal_code_location_location.reload.identifier).to eq("postal_code")
      expect(city_location_location.reload.identifier).to eq("city")
      expect(locode_location_location.reload.identifier).to eq("locode")
      expect(distance_location.reload.identifier).to eq("distance")
    end
  end
end
