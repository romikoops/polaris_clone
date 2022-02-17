# frozen_string_literal: true

require "rails_helper"

module OfferCalculator
  RSpec.describe AsyncCalculationJob, type: :job do
    ActiveJob::Base.queue_adapter = :test
    include ActiveJob::TestHelper

    let(:query) { FactoryBot.create(:journey_query) }

    after do
      clear_enqueued_jobs
    end

    describe "#perform_later" do
      let(:perform_latter) do
        described_class.perform_later(
          query: query, params: {}, pre_carriage: false, on_carriage: false
        )
      end

      it "enqueues the job" do
        expect { perform_latter }.to have_enqueued_job.with(query: query, params: {}, pre_carriage: false, on_carriage: false)
      end
    end

    describe "#perform_now" do
      let(:params) { {} }
      let(:offer_calculator_results) { instance_double(OfferCalculator::Results) }
      let(:result) do
        described_class.perform_now(
          query: query, params: params, pre_carriage: false, on_carriage: false
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
