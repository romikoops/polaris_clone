# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notes::Service do
  describe ".fetch" do
    let(:result_notes) { described_class.new(tender: tender).fetch }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:shipment) { FactoryBot.create(:legacy_shipment, :completed, organization: organization) }
    let(:tender) { Quotations::Tender.last }
    let(:trip) { tender.trip }

    context "when organization notes" do
      let!(:note) { FactoryBot.create(:legacy_note, organization: organization, target: nil, pricings_pricing_id: nil) }
      let!(:irrelevant_notes) do
        [
          FactoryBot.create(:legacy_note, organization: FactoryBot.create(:organizations_organization)),
          FactoryBot.create(:legacy_note, organization: organization)
        ]
      end

      it "returns correct notes" do
        expect(result_notes).to match([note])
      end
    end

    context "when hub notes" do
      let!(:note) {
        FactoryBot.create(:legacy_note, organization: organization, target: tender.origin_hub, pricings_pricing_id: nil)
      }

      it "returns correct notes" do
        expect(result_notes).to match([note])
      end
    end

    context "when nexus notes" do
      let!(:note) {
        FactoryBot.create(:legacy_note,
          organization: organization, target: tender.origin_hub.nexus, pricings_pricing_id: nil)
      }

      it "returns correct notes" do
        expect(result_notes).to match([note])
      end
    end

    context "when country notes" do
      let!(:note) {
        FactoryBot.create(:legacy_note,
          organization: organization, target: tender.origin_hub.nexus.country, pricings_pricing_id: nil)
      }

      it "returns correct notes" do
        expect(result_notes).to match([note])
      end
    end

    context "when pricing notes" do
      let(:pricing) do
        FactoryBot.create(:lcl_pricing,
          itinerary: tender.itinerary,
          organization: organization,
          tenant_vehicle: tender.tenant_vehicle)
      end

      let!(:irrelevant_notes) do
        [
          FactoryBot.create(:legacy_note,
            organization: organization,
            pricings_pricing_id: nil)
        ]
      end

      let!(:note) do
        FactoryBot.create(:legacy_note,
          organization: organization,
          pricings_pricing_id: pricing.id)
      end

      it "returns correct notes" do
        expect(result_notes).to match([note])
      end
    end
  end
end
