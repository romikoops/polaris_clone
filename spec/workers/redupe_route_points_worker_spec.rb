# frozen_string_literal: true

require "rails_helper"
RSpec.describe RedupeRoutePointsWorker, type: :worker do
  let!(:result_set) { FactoryBot.create(:journey_result_set, results: [result]) }
  let(:result) { FactoryBot.build(:journey_result, route_sections: [route_section]) }
  let(:route_point) { FactoryBot.create(:journey_route_point, geo_id: "xxxx") }
  let(:route_section)  { FactoryBot.build(:journey_route_section, from: route_point, to: route_point) }
  let(:carta_result) { FactoryBot.build(:carta_result) }

  describe ".perform" do
    context "with geo_ids form Carta" do
      before do
        allow(Carta::Client).to receive(:lookup).with(id: route_point.geo_id).and_return(carta_result)
        described_class.new.perform
        route_point.reload
      end
      it "duplicates the route points", :aggregate_failures do
        expect(Journey::RoutePoint.count).to eq(3)
        expect(Journey::RoutePoint.all.pluck(:geo_id).uniq).to eq([route_point.geo_id])
      end

      it "updates the data of the route points", :aggregate_failures do
        expect(route_point.postal_code).to eq(carta_result.postal_code)
        expect(route_point.city).to eq(carta_result.locality)
        expect(route_point.street).to eq(carta_result.street)
        expect(route_point.street_number).to eq(carta_result.street_number)
        expect(route_point.administrative_area).to eq(carta_result.administrative_area)
        expect(route_point.country).to eq(carta_result.country)
      end
    end

    context "with nil geo_ids (aka Postal Code from Polaris)" do
      before do
        FactoryBot.create(:locations_name, :reindex, postal_code: "12345", point: route_point.coordinates)
        described_class.new.perform
        route_point.reload
      end
      let(:route_point) { FactoryBot.create(:journey_route_point, name: "12345, Germany", geo_id: nil) }

      it "fetches data from Locations::Name to complete the object" do
        expect(route_point.postal_code).to eq("12345")
      end
    end
  end
end
