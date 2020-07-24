# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::QuotationDecorator do
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let!(:shipment) { FactoryBot.create(:complete_legacy_shipment, with_breakdown: true, with_tenders: true) }
  let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:decorated_quotation) { described_class.new(quotation, context: {scope: scope}) }

  before do
    FactoryBot.create(:quotations_tender, quotation: quotation)
  end

  describe ".tenders" do
    let(:tenders) { decorated_quotation.tenders }

    it "returns the decorated tenders" do
      aggregate_failures do
        expect(tenders.length).to eq(quotation.tenders.count)
        expect(tenders.first).to be_a(Wheelhouse::TenderDecorator)
      end
    end
  end

  describe ".shipment" do
    let(:result) { decorated_quotation.shipment }

    it "returns the shipment" do
      expect(result).to eq(shipment)
    end

    context "when shipment is soft deleted" do
      before do
        shipment.update(deleted_at: Time.zone.now)
      end

      it "returns the shipment" do
        expect(result).to eq(shipment)
      end
    end
  end
end
