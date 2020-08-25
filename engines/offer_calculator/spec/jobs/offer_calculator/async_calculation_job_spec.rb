# frozen_string_literal: true

require "rails_helper"

module OfferCalculator
  RSpec.describe AsyncCalculationJob, type: :job do
    ActiveJob::Base.queue_adapter = :test

    describe "#perform_later" do
      let(:perform_latter) do
        described_class.perform_later(shipment_id: 1, quotation_id: SecureRandom.uuid, user_id: SecureRandom.uuid, wheelhouse: false)
      end

      it "enqueues the job" do
        expect { perform_latter }.to have_enqueued_job
      end
    end

    describe "#perform_now" do
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
      let!(:shipment) { FactoryBot.create(:completed_legacy_shipment, with_breakdown: true, with_tenders: true) }
      let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }
      let(:offer_calculator_results) { instance_double(OfferCalculator::Results) }
      let(:result) do
        described_class.perform_now(
          shipment_id: shipment.id, quotation_id: quotation.id, user_id: shipment.user_id, wheelhouse: false
        )
      end

      before do
        allow(offer_calculator_results).to receive(:perform).and_return(true)
        allow(OfferCalculator::Results).to receive(:new).and_return(offer_calculator_results)
      end

      it "performs the job" do
        expect(result).to eq(true)
      end
    end
  end
end
