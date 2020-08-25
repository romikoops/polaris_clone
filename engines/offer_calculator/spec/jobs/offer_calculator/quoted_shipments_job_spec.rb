# frozen_string_literal: true

require "rails_helper"

module OfferCalculator
  RSpec.describe QuotedShipmentsJob, type: :job do
    ActiveJob::Base.queue_adapter = :test
    let(:shipment) do
      FactoryBot.create(:complete_legacy_shipment,
        with_breakdown: true,
        with_tenders: true)
    end

    describe "#perform_later" do
      it "enqueues the job" do
        expect { described_class.perform_later(shipment_id: shipment.id, send_email: false) }.to have_enqueued_job
      end
    end

    describe "#perform_now" do
      it "performs the job" do
        described_class.perform_now(shipment_id: shipment.id, send_email: false)
        expect(Legacy::Quotation.where(original_shipment_id: shipment.id)).to exist
      end
    end
  end
end
