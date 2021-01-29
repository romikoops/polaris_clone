# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::PricingManipulator do
  include_context "offer_calculator_shared_context"
  let(:load_type) { "cargo_item" }
  let(:cargo_classes) { ["lcl"] }
  let(:trip) { FactoryBot.create(:legacy_trip) }
  let(:schedules) { [OfferCalculator::Schedule.from_trip(trip)] }
  let(:results) {
    described_class.manipulated_pricings(
      request: request,
      associations: associations,
      schedules: schedules
    )
  }

  context "when no trucking exists" do
    before { allow(request).to receive(:has_pre_carriage?).and_return(true) }

    let(:associations) { {truckings: Trucking::Trucking.none} }

    it "returns the one pricing" do
      expect { results }.to raise_error(OfferCalculator::Errors::NoManipulatedPreCarriageFound)
    end
  end

  context "when no export local charges exists" do
    before do
      allow(request).to receive(:has_pre_carriage?).and_return(true)
      allow(OfferCalculator::Service::Manipulators::Truckings).to receive(:results).and_return([trucking_result])
    end

    let(:trucking) { FactoryBot.create(:trucking_trucking) }
    let(:trucking_result) { FactoryBot.build(:manipulator_result, original: trucking, result: trucking.as_json) }
    let(:associations) { {truckings: Trucking::Trucking.all, local_charges: Legacy::LocalCharge.none} }

    it "returns the one pricing" do
      expect { results }.to raise_error(OfferCalculator::Errors::NoManipulatedExportFeesFound)
    end
  end

  context "when no pricings exists" do
    let(:associations) { {pricings: Pricings::Pricing.none} }

    it "raises an error" do
      expect { results }.to raise_error(OfferCalculator::Errors::NoManipulatedPricingsFound)
    end
  end
end
