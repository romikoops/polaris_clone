# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::FeeExperiment do
  include_context "offer_calculator_shared_context"

  let(:associations) do
    {
      "truckings" => Trucking::Trucking.none,
      "local_charges" => Legacy::LocalCharge.none,
      "pricings" => Pricings::Pricing.none
    }
  end
  let(:scope_content) { {} }
  let(:schedules) { [] }
  let(:service) do
    described_class.new(request: request, schedules: schedules, associations: associations)
  end

  before do
    ::Organizations.current_id = organization.id
    allow(service).to receive(:new_charges).and_return([])
    allow(service).to receive(:legacy_charges).and_return([])
    allow(service).to receive(:experimental_charges).and_return([])
    organization.scope.update(content: scope_content)
  end

  describe "#perform" do
    before { service.perform }

    context "when the scope setting is 'legacy'" do
      let(:scope_content) { { calculation_strategy: "legacy" } }

      it "returns the legacy charges", :aggregate_failures do
        expect(service).to have_received(:legacy_charges)
        expect(service).not_to have_received(:experimental_charges)
        expect(service).not_to have_received(:new_charges)
      end
    end

    context "when the scope setting is 'new'" do
      let(:scope_content) { { calculation_strategy: "new" } }

      it "returns the new charges", :aggregate_failures do
        expect(service).to have_received(:new_charges)
        expect(service).not_to have_received(:experimental_charges)
        expect(service).not_to have_received(:legacy_charges)
      end
    end

    context "when the scope setting is 'experiment'" do
      let(:scope_content) { { calculation_strategy: "experiment" } }

      it "returns the experiment charges", :aggregate_failures do
        expect(service).to have_received(:experimental_charges)
        expect(service).not_to have_received(:legacy_charges)
        expect(service).not_to have_received(:new_charges)
      end
    end
  end
end
