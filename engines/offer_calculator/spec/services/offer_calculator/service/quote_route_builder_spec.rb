# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::QuoteRouteBuilder do
  include_context "offer_calculator_shared_context"

  let(:itinerary) do
    FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization)
  end

  let(:tenant_vehicle) do
    FactoryBot.create(:legacy_tenant_vehicle, organization: organization)
  end
  let(:hubs) do
    {
      origin: Legacy::Hub.where(id: itinerary.origin_hub_id),
      destination: Legacy::Hub.where(id: itinerary.destination_hub_id)
    }
  end
  let(:routes) do
    [
      OfferCalculator::Route.new(
        itinerary_id: itinerary.id,
        origin_hub_id: itinerary.origin_hub_id,
        destination_hub_id: itinerary.destination_hub_id,
        tenant_vehicle_id: tenant_vehicle.id
      )
    ]
  end
  let(:scope_content) { {} }
  let(:results) do
    described_class.new(request: request).perform(routes, hubs)
  end
  let(:duration) { OfferCalculator::Schedule::DURATION }
  let(:desired_end_date) { request.cargo_ready_date + duration.days }

  before do
    ::Organizations.current_id = organization.id
    organization.scope.update(content: scope_content)
  end

  describe ".perform" do
    context "without trucking" do
      it "returns the generated Schedule for available routes", :aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.trip.tenant_vehicle_id).to eq(tenant_vehicle.id)
        expect(results.first.etd).to eq(request.cargo_ready_date)
        expect(results.first.eta).to eq(desired_end_date)
      end
    end

    context "with transit_time" do
      before do
        FactoryBot.create(:legacy_transit_time,
          itinerary: itinerary, tenant_vehicle_id: tenant_vehicle.id, duration: duration)
      end

      let(:duration) { 35 }

      it "returns the generated Schedule for available routes", :aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.trip.tenant_vehicle_id).to eq(tenant_vehicle.id)
        expect(results.first.etd).to eq(request.cargo_ready_date)
        expect(results.first.eta).to eq(desired_end_date)
      end
    end

    context "with search_buffer" do
      let(:scope_content) { { search_buffer: 15 } }
      let(:desired_start_date) { 15.days.from_now.beginning_of_day }

      it "returns the generated Schedule for available routes", :aggregate_failures do
        expect(results.first).to be_a(OfferCalculator::Schedule)
        expect(results.first.closing_date).to eq(desired_start_date)
        expect(results.first.etd).to eq(desired_start_date)
      end
    end

    context "with search_buffer & closing_date_buffer" do
      before do
        allow(request).to receive(:cargo_ready_date).and_return(desired_start_date)
      end

      let(:scope_content) { { search_buffer: 5, closing_date_buffer: 5 } }
      let(:desired_start_date) { 15.days.from_now.beginning_of_day }

      it "returns the generated Schedule for available routes", :aggregate_failures do
        expect(results.first.closing_date).to eq(desired_start_date - 5.days)
        expect(results.first.etd).to eq(desired_start_date)
      end
    end

    context "with closing_date_buffer before today" do
      let(:scope_content) { { search_buffer: 0, closing_date_buffer: 5 } }
      let(:desired_start_date) { Time.zone.today.beginning_of_day }

      it "returns the generated Schedule for available routes", :aggregate_failures do
        expect(results.first.closing_date).to eq(desired_start_date)
        expect(results.first.etd).to eq(request.cargo_ready_date)
      end
    end

    context "with cargo_ready_date in the future" do
      let(:desired_start_date) { Time.zone.now.beginning_of_day + 2.months }

      before { allow(request).to receive(:cargo_ready_date).and_return(desired_start_date) }

      it "returns the generated Schedule for available routes", :aggregate_failures do
        expect(results.first.closing_date).to eq(desired_start_date)
        expect(results.first.etd).to eq(desired_start_date)
        expect(results.first.eta).to eq(desired_start_date + 25.days)
      end
    end

    context "with trucking" do
      before do
        google_directions = instance_double("Trucking::GoogleDirections",
          driving_time_in_seconds: 10_000, driving_time_in_seconds_for_trucks: 14_000)
        allow(Trucking::GoogleDirections).to receive(:new).and_return(google_directions)
        allow(request).to receive(:pre_carriage?).and_return(true)
        allow(request).to receive(:pickup_address).and_return(pickup_address)
      end

      let(:pickup_address) { FactoryBot.create(:gothenburg_address) }

      it "returns the generated Schedule for available routes", :aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.trip.tenant_vehicle_id).to eq(tenant_vehicle.id)
        expect(results.first.etd).to eq(request.cargo_ready_date)
        expect(results.first.eta).to eq(desired_end_date)
      end
    end
  end
end
