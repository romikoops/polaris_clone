# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuotationDecorator do
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let!(:shipment) { FactoryBot.create(:completed_legacy_shipment, with_breakdown: true, with_tenders: true) }
  let(:quotation) { Quotations::Quotation.find_by(legacy_shipment: shipment) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:decorated_quotation) { described_class.new(quotation, context: {scope: scope}) }

  describe ".legacy_json" do
    let(:result) { decorated_quotation.legacy_json }

    it "returns the legacy response format" do
      aggregate_failures do
        expect(result.dig(:shipment).id).to eq(shipment.id)
        expect(result.dig(:quotationId)).to eq(quotation.id)
        expect(result.dig(:completed)).to be_present
      end
    end
  end

  describe ".cargo_units" do
    context "when lcl" do
      let!(:shipment) { FactoryBot.create(:completed_legacy_shipment, with_breakdown: true, with_tenders: true, load_type: "cargo_item") }

      it "returns the legacy response format" do
        cargo_units = decorated_quotation.cargo_units
        expect(cargo_units).to eq shipment.cargo_units.map(&:with_cargo_type)
      end
    end

    context "when aggregated lcl cargo" do
      let!(:shipment) { FactoryBot.create(:completed_legacy_shipment, with_breakdown: true, with_tenders: true, with_aggregated_cargo: true, load_type: "cargo_item") }

      it "returns the legacy response format" do
        cargo_units = decorated_quotation.cargo_units
        expect(cargo_units).to eq [shipment.aggregated_cargo]
      end
    end
  end

  describe ".results" do
    let(:results) { decorated_quotation.results }
    let(:charge_breakdown) { FactoryBot.create(:legacy_charge_breakdown, shipment: shipment) }

    context "when a charge breakdown is deleted" do
      before do
        FactoryBot.create(:quotations_tender, quotation: quotation, charge_breakdown: charge_breakdown)
        charge_breakdown.destroy
      end

      it "returns the tenders, including the one with a deleted deleted charge breakdown" do
        expect(results.count).to eq(2)
      end
    end
  end
end
