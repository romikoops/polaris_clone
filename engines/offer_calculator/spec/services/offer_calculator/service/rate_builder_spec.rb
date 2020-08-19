# frozen_string_literal: true

require "rails_helper"
require_relative "../../../shared_contexts/basic_setup.rb"

RSpec.describe OfferCalculator::Service::RateBuilder do
  include_context "offer_calculator_shared_context"
  let(:load_type) { "cargo_item" }
  let(:cargo_classes) { ["lcl"] }
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:manipulated_result) { FactoryBot.build(:manipulator_result, original: pricing, result: pricing.as_json) }
  let(:trucking) { FactoryBot.create(:trucking_trucking, organization: organization) }
  let(:inputs) do
    {
      pricings: [manipulated_result],
      truckings: [FactoryBot.build(:manipulator_result, original: trucking, result: trucking.as_json)]
    }
  end
  let(:results) { described_class.fees(shipment: shipment, quotation: quotation, inputs: inputs) }

  before do
    FactoryBot.create(:cloned_cargo, quotation_id: quotation.id)
  end

  context "with only freight rates" do
    before do
      allow(quotation).to receive(:pickup_address).and_return(FactoryBot.create(:gothenburg_address))
    end

    it "returns the charges" do
      aggregate_failures do
        expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
        expect(results.count).to eq(3)
      end
    end
  end

  context "with errors" do
    before do
      allow(manipulated_result).to receive(:fees).and_return(true)
    end

    it "raises an error" do
      expect { results }.to raise_error(OfferCalculator::Errors::RateBuilderError)
    end
  end
end
