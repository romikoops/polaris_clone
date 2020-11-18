# frozen_string_literal: true

require "rails_helper"

module Locations
  RSpec.describe Location, type: :model do
    context "validations" do
      let(:location) { FactoryBot.create(:locations_location) }
      it "is valid with valid attributes" do
        expect(FactoryBot.build(:locations_location)).to be_valid
      end

      it "is unique" do
        location_1 = FactoryBot.create(:locations_location)
        expect(FactoryBot.build(:locations_location, osm_id: location_1.osm_id)).not_to be_valid
      end
    end

    describe ".contains" do
      let(:lat) { 31.310542 }
      let(:lon) { 121.3496233 }

      context "with regular polygon" do
        let!(:location) { FactoryBot.create(:locations_location, :in_china) }

        it "finds the correct Location by lat lng pair" do
          results = Locations::Location.contains(point: location.bounds.centroid)
          expect(results).to include(location)
        end
      end

      context "with multi polygon" do
        let!(:location) { FactoryBot.create(:locations_location, :in_sweden_large) }

        before do
          FactoryBot.create(:locations_location, bounds: FactoryBot.build(:legacy_bounds))
        end

        it "finds the correct Location by lat lng pair" do
          results = Locations::Location.contains(point: location.bounds.centroid)
          expect(results).to include(location)
        end
      end
    end
  end
end
