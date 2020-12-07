# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::QuotedShipmentsJob, type: :job do
  let(:shipment) do
    FactoryBot.create(:complete_legacy_shipment,
      with_breakdown: true,
      with_tenders: true)
  end

  it "performs the job" do
    described_class.perform_now(shipment_id: shipment.id, send_email: false)
    expect(Legacy::Quotation.where(original_shipment_id: shipment.id)).to exist
  end
end
