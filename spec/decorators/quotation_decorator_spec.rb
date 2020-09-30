# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuotationDecorator do
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let!(:shipment) { FactoryBot.create(:completed_legacy_shipment, with_breakdown: true, with_tenders: true) }
  let(:quotation) { Quotations::Quotation.find_by(legacy_shipment: shipment) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:decorated_quotation) { described_class.new(quotation, context: {scope: scope}) }
  let(:cargo) { quotation.cargo }

  before do
    FactoryBot.create(:cargo_cargo, quotation_id: quotation.id)
  end

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

  describe ".origin" do
    let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment: shipment, pickup_address: address) }

    context "without nexus" do
      before do
        allow(quotation).to receive(:origin_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_quotation.origin).to eq("#{address.country.code}-#{address&.zip_code}")
      end
    end

    context "with nexus and no pickup address" do
      before do
        allow(quotation).to receive(:pickup_address).and_return(nil)
      end

      it "returns the name of the origin nexus" do
        expect(decorated_quotation.origin).to eq(quotation.origin_nexus.name)
      end
    end

    context "without nexus or postal code" do
      before do
        allow(address).to receive(:zip_code).and_return(nil)
        allow(quotation).to receive(:origin_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_quotation.origin).to eq(address.city)
      end
    end
  end

  describe ".destination" do
    let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment: shipment, delivery_address: address) }

    context "without nexus" do
      before do
        allow(quotation).to receive(:destination_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_quotation.destination).to eq("#{address.country.code}-#{address&.zip_code}")
      end
    end

    context "with nexus and no delivery address" do
      before do
        allow(quotation).to receive(:delivery_address).and_return(nil)
      end

      it "returns the destination_nexus name" do
        expect(decorated_quotation.destination).to eq(quotation.destination_nexus.name)
      end
    end

    context "without nexus or postal code" do
      before do
        allow(address).to receive(:zip_code).and_return(nil)
        allow(quotation).to receive(:destination_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_quotation.destination).to eq(address.city)
      end
    end
  end

  describe ".origin_city" do
    let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment: shipment, pickup_address: address) }

    context "without nexus" do
      before do
        allow(quotation).to receive(:origin_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_quotation.origin_city).to eq(address.city)
      end
    end

    context "with nexus" do
      before do
        allow(quotation).to receive(:pickup_address).and_return(nil)
      end

      it "returns the nexus name when address is nil" do
        expect(decorated_quotation.origin_city).to eq(quotation.origin_nexus.name)
      end
    end
  end

  describe ".destination_city" do
    let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment: shipment, delivery_address: address) }

    context "without nexus" do
      before do
        allow(quotation).to receive(:destination_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_quotation.destination_city).to eq(address.city)
      end
    end

    context "with nexus" do
      before do
        allow(quotation).to receive(:delivery_address).and_return(nil)
      end

      it "returns the destination_nexus name" do
        expect(decorated_quotation.destination_city).to eq(quotation.destination_nexus.name)
      end
    end
  end

  describe "total_weight" do
    context "when lcl" do
      it "returns the total weight of the cargo items" do
        expect(decorated_quotation.total_weight).to eq(cargo.total_weight.format(".1%<value>f"))
      end
    end

    context "when aggregate lcl" do
      let(:aggregated) { true }

      it "returns the total weight of the aggregated cargo" do
        expect(decorated_quotation.total_weight).to eq(cargo.total_weight.format(".1%<value>f"))
      end
    end

    context "when fcl" do
      let(:load_type) { "container" }

      it "returns the total weight of the containers" do
        expect(decorated_quotation.total_weight).to eq(cargo.total_weight.format(".1%<value>f"))
      end
    end
  end

  describe "total_volume" do
    context "when lcl" do
      it "returns the total weight of the cargo items" do
        expect(decorated_quotation.total_volume).to eq(cargo.total_volume.format(".1%<value>f"))
      end
    end

    context "when aggregate lcl" do
      let(:aggregated) { true }

      it "returns the total weight of the aggregated cargo" do
        expect(decorated_quotation.total_volume).to eq(cargo.total_volume.format(".1%<value>f"))
      end
    end
  end
end
