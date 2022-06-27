# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::FeeBuilder do
  include_context "offer_calculator_shared_context"

  let(:associations) do
    {
      "truckings" => Trucking::Trucking.none,
      "local_charges" => Legacy::LocalCharge.none,
      "pricings" => Pricings::Pricing.none
    }
  end
  let(:schedules) { [] }

  describe "#perform" do
    before do
      ::Organizations.current_id = organization.id
      allow(OfferCalculator::Service::Charges::Generator).to receive(:results).and_return([])
      described_class.fees(request: request, schedules: schedules, associations: associations)
    end

    it "calls the Generator class for each association with each association" do
      expect(OfferCalculator::Service::Charges::Generator).to have_received(:results).at_least(:once).with(
        association: associations["truckings"],
        request: request,
        schedules: schedules
      )
    end

    it "calls the Generator class for each association with the local charges association" do
      expect(OfferCalculator::Service::Charges::Generator).to have_received(:results).at_least(:once).with(
        association: associations["local_charges"],
        request: request,
        schedules: schedules
      )
    end

    it "calls the Generator class for each association with the pricings association" do
      expect(OfferCalculator::Service::Charges::Generator).to have_received(:results).at_least(:once).with(
        association: associations["pricings"],
        request: request,
        schedules: schedules
      )
    end
  end
end
