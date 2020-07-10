require "rails_helper"

RSpec.describe QuotedShipmentsJob, type: :job do
  ActiveJob::Base.queue_adapter = :test
  let(:shipment) {
    FactoryBot.create(:complete_legacy_shipment,
      with_breakdown: true,
      with_tenders: true)
  }

  describe "#perform_later" do
    it "enqueues the job" do
      expect {
        QuotedShipmentsJob.perform_later(shipment: shipment, send_email: false)
      }.to have_enqueued_job
    end
  end

  describe "#perform_now" do
    it "performs the job" do
      QuotedShipmentsJob.perform_now(shipment: shipment, send_email: false)
      expect(Legacy::Quotation.exists?(original_shipment_id: shipment.id)).to be_truthy
    end
  end
end
