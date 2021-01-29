# frozen_string_literal: true

require "rails_helper"

RSpec.describe Wheelhouse::ExcelWriterService do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:shipment) {
    FactoryBot.create(:legacy_shipment, with_breakdown: true, with_tenders: true, user: user,
                                        organization: organization)
  }
  let(:quotation) { Quotations::Quotation.find_by(legacy_shipment_id: shipment) }
  let(:tender_ids) { shipment.charge_breakdowns.pluck(:tender_id) }
  let(:origin_hub) { FactoryBot.create(:hamburg_hub, organization: organization) }
  let(:result) { described_class.new(tender_ids: tender_ids, quotation_id: quotation.id).quotation_sheet }

  before do
    ::Organizations.current_id = organization.id
  end

  xdescribe ".quotation_sheet" do
    context "with tender ids" do
      let(:tender) { Quotations::Tender.find(tender_ids.first) }

      before do
        tender.update(name: "Ningbo - Ipswich")
        pricing = FactoryBot.create(:lcl_pricing,
          organization: organization,
          load_type: tender.load_type,
          tenant_vehicle: tender.tenant_vehicle,
          itinerary: tender.itinerary)
        FactoryBot.create(:legacy_note, pricings_pricing_id: pricing.id, organization: organization, remarks: true)
        tender_2 = FactoryBot.create(:quotations_tender, quotation: quotation, origin_hub: origin_hub)
        FactoryBot.create(:legacy_charge_breakdown, shipment: shipment, tender_id: tender_2.id)
        tender.line_items.first.update(amount: Money.new(50, "AED"))
      end

      it "creates the specified tender worksheets, summary and attaches the file to result" do
        writer = described_class.new(tender_ids: [], quotation_id: quotation.id)
        result = writer.quotation_sheet
        aggregate_failures do
          expect(result.file).to be_attached
          expect(writer.work_book.sheets.count).to eq(3)
          expect(writer.work_book.sheets.first.name).to eq("Summary")
        end
      end
    end
  end
end
