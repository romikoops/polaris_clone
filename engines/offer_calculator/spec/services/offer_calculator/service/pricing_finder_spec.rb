# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::PricingFinder do
  include_context "offer_calculator_shared_context"
  let(:load_type) { "cargo_item" }
  let(:cargo_classes) { ["lcl"] }
  let(:trip) { FactoryBot.create(:legacy_trip) }
  let(:schedules) { [OfferCalculator::Schedule.from_trip(trip)] }
  let(:results) { described_class.pricings(request: request, schedules: schedules) }

  context "when no trucking exists" do
    before do
      allow(request).to receive(:pre_carriage?).and_return(true)
      allow(request).to receive(:pickup_address).and_return(FactoryBot.create(:legacy_address, :gothenburg))
    end

    it "raises an error" do
      expect { results }.to raise_error(OfferCalculator::Errors::NoPreCarriageFound)
    end
  end

  context "when no export local charges exists" do
    before do
      FactoryBot.create(:trucking_trucking, organization: organization)
      allow(request).to receive(:pre_carriage?).and_return(true)
      allow(request).to receive(:on_carriage?).and_return(false)
      allow(OfferCalculator::Service::Finders::Truckings).to receive(:prices).and_return(Trucking::Trucking.all)
    end

    it "raises an error" do
      expect { results }.to raise_error(OfferCalculator::Errors::NoExportFeesFound)
    end
  end

  context "when no export local charges exists but local_charges_required_with_trucking is `false`" do
    before do
      FactoryBot.create(:trucking_trucking, organization: organization)
      FactoryBot.create(:pricings_pricing, organization: organization)
      allow(request).to receive(:pre_carriage?).and_return(true)
      allow(request).to receive(:on_carriage?).and_return(false)
      allow(OrganizationManager::ScopeService).to receive(:new)
        .and_return(instance_double("ScopeService", fetch: { local_charges_required_with_trucking: false }))
      allow(OfferCalculator::Service::Finders::Truckings).to receive(:prices).and_return(Trucking::Trucking.all)
      allow(OfferCalculator::Service::Finders::Pricings).to receive(:prices).and_return(Pricings::Pricing.all)
    end

    it "does not raise an error" do
      expect { results }.not_to raise_error(OfferCalculator::Errors::NoExportFeesFound)
    end
  end

  context "when no pricings exists" do
    before do
      allow(request).to receive(:pre_carriage?).and_return(false)
      allow(request).to receive(:on_carriage?).and_return(false)
      allow(OfferCalculator::Service::Finders::Truckings).to receive(:prices).and_return(Trucking::Trucking.all)
    end

    it "raises an error" do
      expect { results }.to raise_error(OfferCalculator::Errors::NoPricingsFound)
    end
  end
end
