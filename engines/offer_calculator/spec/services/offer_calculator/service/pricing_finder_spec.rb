# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::PricingFinder do
  include_context "offer_calculator_shared_context"
  let(:load_type) { "cargo_item" }
  let(:cargo_classes) { ["lcl"] }
  let(:trip) { FactoryBot.create(:legacy_trip) }
  let(:schedules) { [OfferCalculator::Schedule.from_trip(trip)] }
  let(:results) { described_class.pricings(shipment: shipment, quotation: quotation, schedules: schedules) }

  context "when no trucking exists" do
    before { allow(shipment).to receive(:has_pre_carriage?).and_return(true) }

    it "raises an error" do
      expect { results }.to raise_error(OfferCalculator::Errors::NoPreCarriageFound)
    end
  end

  context "when no export local charges exists" do
    before do
      FactoryBot.create(:trucking_trucking)
      allow(shipment).to receive(:has_pre_carriage?).and_return(true)
      allow(OfferCalculator::Service::Finders::Truckings).to receive(:prices).and_return(Trucking::Trucking.all)
    end

    it "raises an error" do
      expect { results }.to raise_error(OfferCalculator::Errors::NoExportFeesFound)
    end
  end

  context "when no pricings exists" do
    it "raises an error" do
      expect { results }.to raise_error(OfferCalculator::Errors::NoPricingsFound)
    end
  end
end
