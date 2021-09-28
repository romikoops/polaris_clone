# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferSorter do
  include_context "offer_calculator_shared_context"
  include_context "complete_route_with_trucking"

  let(:cargo_classes) { %w[fcl_20] }
  let(:request_params) do
    FactoryBot.build(:journey_request_params,
      cargo_trait,
      origin_hub: origin_hub,
      destination_hub: destination_hub,
      pickup_address: pickup_address,
      delivery_address: delivery_address)
  end
  let(:request) { FactoryBot.build(:offer_calculator_request, params: request_params, cargo_trait: cargo_trait, organization: organization) }
  let(:load_type) { "container" }
  let(:cargo_trait) { load_type == "container" ? :fcl : :lcl }
  let(:schedules) { trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) } }
  let(:charges) do
    charge_inputs.flat_map do |object|
      FactoryBot.build(:calculators_result_from_raw,
        raw_object: object,
        request: request)
    end
  end
  let(:charge_inputs) { (pricings | local_charges | truckings) }
  let(:offers) { described_class.sorted_offers(request: request, charges: charges, schedules: schedules) }

  describe ".sorted_offers" do
    it "returns one offer" do
      expect(offers.length).to eq(1)
    end

    context "when mandatory local charges is set but no local charges exists" do
      let!(:local_charges) do
        cargo_classes.map do |cc|
          FactoryBot.create(:legacy_local_charge,
            direction: "export",
            hub: origin_hub,
            load_type: cc,
            organization: organization,
            tenant_vehicle: tenant_vehicle)
        end
      end
      let(:mandatory_charge) { FactoryBot.create(:legacy_mandatory_charge, import_charges: true, export_charges: true) }
      let(:charge_inputs) { (pricings | local_charges) }
      let(:itinerary) { FactoryBot.create(:legacy_itinerary, origin_hub: origin_hub, destination_hub: destination_hub, organization: organization) }
      let(:origin_hub) { FactoryBot.create(:hamburg_hub, organization: organization, mandatory_charge: mandatory_charge) }
      let(:destination_hub) { FactoryBot.create(:shanghai_hub, organization: organization, mandatory_charge: mandatory_charge) }

      it "returns an offer even though no import charges are found" do
        expect(offers.first.section_keys).to eq(%w[export cargo])
      end
    end

    context "when trucking has carrier_lock set to `true`" do
      let(:truckings) do
        cargo_classes.map do |cargo_class|
          FactoryBot.create(:trucking_with_unit_rates,
            hub: itinerary.origin_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: load_type,
            truck_type: truck_type,
            tenant_vehicle: trucking_tenant_vehicle,
            location: pickup_trucking_location)
        end
      end
      let(:trucking_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization, mode_of_transport: "truck_carriage", carrier_lock: true) }

      before do
        allow(request).to receive(:carriage?).and_return(true)
        allow(request).to receive(:pre_carriage?).and_return(true)
        allow(request).to receive(:on_carriage?).and_return(true)
      end

      it "returns no offers as carrier dont match" do
        expect { offers }.to raise_error(OfferCalculator::Errors::NoValidOffers)
      end
    end

    context "when local_charges_required_with_trucking is false and trucking charges have been prepared" do
      let(:charge_inputs) { pricings | truckings }

      before do
        allow(request).to receive(:carriage?).and_return(true)
        allow(request).to receive(:pre_carriage?).and_return(true)
        allow(request).to receive(:on_carriage?).and_return(true)
        organization.scope.update(content: { local_charges_required_with_trucking: false })
      end

      it "returns an offer even though no import charges are found" do
        expect(offers.first.section_keys).to eq(%w[trucking_pre cargo trucking_on])
      end
    end
  end
end
