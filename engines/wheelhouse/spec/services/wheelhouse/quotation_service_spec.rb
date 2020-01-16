# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::QuotationService do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}) }
  let(:origin_nexus) { FactoryBot.create(:legacy_nexus, hubs: [origin_hub]) }
  let(:destination_nexus) { FactoryBot.create(:legacy_nexus, hubs: [destination_hub]) }
  let(:origin_hub) { FactoryBot.create(:legacy_hub, tenant: tenant, name: 'Hub 1') }
  let(:destination_hub) { FactoryBot.create(:legacy_hub, tenant: tenant, name: 'Hub 2') }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, tenant: tenant) }
  let(:routes) { [OfferCalculator::Route.new] }

  describe '#results' do
    let(:shipment_update_handler_double) { double }
    let(:shipment_update_methods) { %i[update_selected_day update_cargo_units update_trucking update_nexuses] }
    let(:shipping_info) { {} }
    let(:input) do
      { tenant_id: tenant.id,
        user_id: user.id,
        direction: direction,
        load_type: load_type,
        selected_date: Time.zone.today,
        origin: { nexus_id: origin_nexus },
        destination: { nexus_id: destination_nexus },
      }
    end

    let(:offercalculator_proxies) do
      {
        hub_finder: instance_double(OfferCalculator::Service::HubFinder, perform: { origin: origin_hub, destination: destination_hub }),
        route_finder: instance_double(OfferCalculator::Service::RouteFinder, perform: routes),
        route_filter: instance_double(OfferCalculator::Service::RouteFilter, perform: routes),
        schedule_finder: instance_double(OfferCalculator::Service::ScheduleFinder, perform: nil),
        trucking_data_builder: instance_double(OfferCalculator::Service::TruckingDataBuilder, perform: nil),
        detail_schedules_builder: instance_double(OfferCalculator::Service::DetailedSchedulesBuilder, perform: [])
      }
    end

    before do
      shipment_update_methods.each do |method_name|
        allow(shipment_update_handler_double).to receive(method_name).and_return(true)
      end
      allow(OfferCalculator::Service::ShipmentUpdateHandler).to receive(:new).and_return(shipment_update_handler_double)
      allow(OfferCalculator::Service::HubFinder).to receive(:new).and_return(offercalculator_proxies[:hub_finder])
      allow(OfferCalculator::Service::RouteFinder).to receive(:new).and_return(offercalculator_proxies[:route_finder])
      allow(OfferCalculator::Service::RouteFilter).to receive(:new).and_return(offercalculator_proxies[:route_filter])
      allow(OfferCalculator::Service::ScheduleFinder).to receive(:new).and_return(offercalculator_proxies[:schedule_finder])
      allow(OfferCalculator::Service::TruckingDataBuilder).to receive(:new).and_return(offercalculator_proxies[:trucking_data_builder])
      allow(OfferCalculator::Service::DetailedSchedulesBuilder).to receive(:new).and_return(offercalculator_proxies[:detail_schedules_builder])
    end

    context 'when initialization' do
      it 'initializes the shipment update handler and updates the necessary attributes' do
        described_class.new(quotation_details: input.with_indifferent_access, shipping_info: shipping_info)
        shipment_update_methods.each do |method|
          expect(shipment_update_handler_double).to have_received(method)
        end
      end
    end

    context 'when proxying calls to the offer_calculator service' do
      let(:load_type) { 'container' }

      it 'proxies :perform call to the correct classes' do
        offercalculator_proxies.each do |_key, method_double|
          described_class.new(quotation_details: input.with_indifferent_access, shipping_info: shipping_info).results
          expect(method_double).to have_received(:perform).at_least(:once)
        end
      end
    end
  end
end
