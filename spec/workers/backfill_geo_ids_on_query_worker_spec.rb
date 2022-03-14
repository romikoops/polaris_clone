# frozen_string_literal: true

require "rails_helper"
RSpec.describe BackfillGeoIdsOnQueryWorker, type: :worker, skip: "Validations added that invalidate the spec" do
  describe "#perform" do
    context "when results present for a query" do
      let!(:query) { FactoryBot.create(:journey_query, origin_geo_id: nil, destination_geo_id: nil, result_count: 1) }

      before do
        described_class.new.perform
        query.reload
      end

      it "updates the query with the geo id from the origin Route Point" do
        expect(query.origin_geo_id).to eq(query.results.first.route_sections.order(order: :asc).first.from.geo_id)
      end

      it "updates the query with the geo id from the destination Route Point" do
        expect(query.destination_geo_id).to eq(query.results.first.route_sections.order(order: :asc).last.to.geo_id)
      end
    end

    context "when results are present for a query but route section's route points contain nil geo_ids" do
      let(:query) { FactoryBot.create(:journey_query, origin: "DEHAM", destination: "CNSGH", origin_geo_id: nil, destination_geo_id: nil) }
      let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: query.origin) }
      let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: query.destination) }
      let(:route_point_origin) { FactoryBot.build(:journey_route_point, name: "hamburg", locode: "DEHAM", geo_id: "itsmycargo:locode:67ogmgddqiju2ii") }
      let(:route_point_destination) { FactoryBot.build(:journey_route_point, name: "shanghai", locode: "CNSGH", geo_id: nil) }
      let(:result) do
        FactoryBot.create(:journey_result,
          sections: 0,
          query: query,
          route_sections: [
            FactoryBot.build(:journey_route_section,
              from: route_point_origin,
              to: route_point_destination)
          ])
      end

      before do
        result
        allow(Carta::Client).to receive(:suggest).with(query: query.origin).and_return(origin)
        allow(Carta::Client).to receive(:suggest).with(query: query.destination).and_return(destination)

        described_class.new.perform
        query.reload
      end

      context "when route sections from and two contain `nil` geo_ids" do
        let(:route_point_origin) { FactoryBot.build(:journey_route_point, name: "hamburg", locode: "DEHAM", geo_id: nil) }

        it "updates the query origin with the suggested origin geo id from carta" do
          expect(query.origin_geo_id).to eq(origin.id)
        end

        it "updates the query destination with the suggested destination geo id from carta" do
          expect(query.destination_geo_id).to eq(destination.id)
        end
      end

      context "when `from` route point contain valid geo_id and `to` route point contains nil geo_id for the route section" do
        it "updates the query origin with route_points from geo_id" do
          expect(query.origin_geo_id).to eq(route_point_origin.geo_id)
        end

        it "updates the query destination with the suggested destination geo id from carta" do
          expect(query.destination_geo_id).to eq(destination.id)
        end
      end
    end

    context "when query origin and destination contains a valid address which carta can suggest" do
      let!(:query) { FactoryBot.create(:journey_query, origin: "DEHAM", destination: "CNSGH", origin_geo_id: nil, destination_geo_id: nil) }
      let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: query.origin) }
      let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: query.destination) }

      before do
        allow(Carta::Client).to receive(:suggest).with(query: query.origin).and_return(origin)
        allow(Carta::Client).to receive(:suggest).with(query: query.destination).and_return(destination)

        described_class.new.perform
        query.reload
      end

      it "updates the query origin with the suggested origin geo id from carta" do
        expect(query.origin_geo_id).to eq(origin.id)
      end

      it "updates the query destination with the suggested destination geo id from carta" do
        expect(query.destination_geo_id).to eq(destination.id)
      end
    end

    context "when query origin and destination contains a invalid address which carta cannot suggest" do
      let!(:query) { FactoryBot.create(:journey_query, origin: "weird origin", destination: "unknown destination", origin_geo_id: nil, destination_geo_id: nil) }
      let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode") }
      let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode") }

      before do
        allow(Carta::Client).to receive(:suggest).with(query: query.origin).and_raise(Carta::Client::LocationNotFound)
        allow(Carta::Client).to receive(:suggest).with(query: query.destination).and_raise(Carta::Client::LocationNotFound)
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: query.origin_coordinates.y, longitude: query.origin_coordinates.x).and_return(origin)
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: query.destination_coordinates.y, longitude: query.destination_coordinates.x).and_return(destination)

        described_class.new.perform
        query.reload
      end

      it "updates the query origin with the origin geo id from carta by reverse geo coding query lat and lon coordinates" do
        expect(query.origin_geo_id).to eq(origin.id)
      end

      it "updates the query origin with the destination geo id from carta by reverse geo coding query lat and lon coordinates" do
        expect(query.destination_geo_id).to eq(destination.id)
      end
    end

    context "when query origin and/or destination coordinates is 0.0 and origin or destination conain invalid address that carta cannot suggest" do
      let!(:query) do
        FactoryBot.create(:journey_query,
          origin: "weird origin",
          origin_coordinates: RGeo::Geos.factory(srid: 4326).point(0.0, 0.0),
          destination_coordinates: RGeo::Geos.factory(srid: 4326).point(0.0, 0.0),
          origin_geo_id: nil,
          destination_geo_id: nil)
      end

      before do
        allow(Carta::Client).to receive(:suggest).with(query: query.origin).and_raise(Carta::Client::LocationNotFound)
        allow(Carta::Client).to receive(:suggest).with(query: query.destination).and_raise(Carta::Client::LocationNotFound)

        described_class.new.perform
        query.reload
      end

      it "the queries origin will still be nil" do
        expect(query.origin_geo_id).to eq(nil)
      end

      it "the queries destination will still be nil" do
        expect(query.destination_geo_id).to eq(nil)
      end
    end
  end
end
