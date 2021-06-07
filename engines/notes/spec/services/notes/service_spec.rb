# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notes::Service do
  describe ".fetch" do
    let(:result_notes) { described_class.new(itinerary: itinerary, tenant_vehicle: tenant_vehicle).fetch }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
    let(:itinerary) { FactoryBot.create(:legacy_itinerary, organization: organization) }
    let!(:pricing) do
      FactoryBot.create(:pricings_pricing,
        itinerary: itinerary,
        tenant_vehicle: tenant_vehicle,
        organization: organization)
    end

    context "when notes have duplicate bodies" do
      let(:body) { "Test" }

      before do
        FactoryBot.create(:legacy_note, organization: organization, target: nil, body: body, pricings_pricing_id: nil)
        FactoryBot.create(:legacy_note, organization: organization, target: nil, body: body, pricings_pricing_id: nil)
      end

      it "returns correct notes" do
        expect(result_notes.to_a.pluck(:body)).to match([body])
      end
    end

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
      let!(:note) do
        FactoryBot.create(:legacy_note, organization: organization, target: itinerary.origin_hub, pricings_pricing_id: nil)
      end

      it "returns correct notes" do
        expect(result_notes).to match([note])
      end
    end

    context "when nexus notes" do
      let!(:note) do
        FactoryBot.create(:legacy_note,
          organization: organization, target: itinerary.origin_hub.nexus, pricings_pricing_id: nil)
      end

      it "returns correct notes" do
        expect(result_notes).to match([note])
      end
    end

    context "when country notes" do
      let!(:note) do
        FactoryBot.create(:legacy_note,
          organization: organization, target: itinerary.origin_hub.nexus.country, pricings_pricing_id: nil)
      end

      it "returns correct notes" do
        expect(result_notes).to match([note])
      end
    end

    context "when pricing notes" do
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
