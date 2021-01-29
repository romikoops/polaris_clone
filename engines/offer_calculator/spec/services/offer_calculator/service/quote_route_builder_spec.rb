# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::QuoteRouteBuilder do
  include_context "offer_calculator_shared_context"

  let(:itinerary) {
    FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization)
  }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:tenant_vehicle) {
    FactoryBot.create(:legacy_tenant_vehicle, organization: organization)
  }
  let(:hubs) do
    {
      origin: Legacy::Hub.where(id: origin_hub.id),
      destination: Legacy::Hub.where(id: destination_hub.id)
    }
  end
  let(:routes) do
    [
      OfferCalculator::Route.new(
        itinerary_id: itinerary.id,
        origin_stop_id: itinerary.stops.first.id,
        destination_stop_id: itinerary.stops.last.id,
        tenant_vehicle_id: tenant_vehicle.id
      )
    ]
  end
  let(:scope_content) { {} }
  let(:results) {
    described_class.new(request: request).perform(routes, hubs)
  }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_scope, target: organization, content: scope_content)
  end

  describe ".perform" do
    context "without trucking" do
      it "returns the generated Schedule for available routes" do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.trip.tenant_vehicle_id).to eq(tenant_vehicle.id)
          expect(results.first.etd).to eq(Time.zone.today.beginning_of_day)
          expect(results.first.eta).to eq(OfferCalculator::Schedule.quote_trip_end_date)
        end
      end
    end

    context "with transit_time" do
      before do
        FactoryBot.create(:legacy_transit_time,
          itinerary: itinerary, tenant_vehicle_id: tenant_vehicle.id, duration: 35)
      end

      let(:desired_end_date) { 35.days.from_now.beginning_of_day }

      it "returns the generated Schedule for available routes" do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.trip.tenant_vehicle_id).to eq(tenant_vehicle.id)
          expect(results.first.etd).to eq(Time.zone.today.beginning_of_day)
          expect(results.first.eta).to eq(desired_end_date)
        end
      end
    end

    context "with search_buffer" do
      let(:scope_content) { {search_buffer: 15} }
      let(:desired_start_date) { 15.days.from_now.beginning_of_day }

      it "returns the generated Schedule for available routes" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Schedule)
          expect(results.first.closing_date).to eq(desired_start_date)
          expect(results.first.etd).to eq(desired_start_date)
        end
      end
    end

    context "with search_buffer & closing_date_buffer" do
      let(:scope_content) { {search_buffer: 15, closing_date_buffer: 5} }
      let(:desired_start_date) { 15.days.from_now.beginning_of_day }

      it "returns the generated Schedule for available routes" do
        aggregate_failures do
          expect(results.first.closing_date).to eq(desired_start_date - 5.days)
          expect(results.first.etd).to eq(desired_start_date)
        end
      end
    end

    context "with closing_date_buffer before today" do
      let(:scope_content) { {search_buffer: 0, closing_date_buffer: 5} }
      let(:desired_start_date) { Time.zone.now.beginning_of_day }

      it "returns the generated Schedule for available routes" do
        aggregate_failures do
          expect(results.first.closing_date).to eq(desired_start_date)
          expect(results.first.etd).to eq(desired_start_date)
        end
      end
    end

    context "with trucking" do
      before do
        google_directions = instance_double("Trucking::GoogleDirections",
          driving_time_in_seconds: 10_000, driving_time_in_seconds_for_trucks: 14_000)
        allow(Trucking::GoogleDirections).to receive(:new).and_return(google_directions)
        allow(request).to receive(:has_pre_carriage?).and_return(true)
        allow(request).to receive(:pickup_address).and_return(pickup_address)
      end

      let(:pickup_address) { FactoryBot.create(:gothenburg_address) }

      it "returns the generated Schedule for available routes" do
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.trip.tenant_vehicle_id).to eq(tenant_vehicle.id)
          expect(results.first.etd).to eq(Time.zone.today.beginning_of_day)
          expect(results.first.eta).to eq(OfferCalculator::Schedule.quote_trip_end_date)
        end
      end
    end
  end
end
