# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuotedShipmentsService, type: :service do
  let(:shipment) {
    FactoryBot.create(:complete_legacy_shipment,
      itinerary: itinerary,
      trip: trip,
      with_breakdown: true,
      with_tenders: true,
      organization: organization,
      trucking: trucking)
  }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:send_email) { false }
  let(:trucking) { {} }
  let(:service) { described_class.new(shipment: shipment, send_email: send_email) }
  let(:quotation) { Legacy::Quotation.find_by(original_shipment_id: shipment) }
  let(:quotation_shipments) { quotation.shipments }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }

  describe ".perform" do
    context "without existing quotation" do
      before do
        service.perform
      end

      it "creates a quotation and shipments" do
        aggregate_failures do
          expect(quotation_shipments.length).to eq(shipment.charge_breakdowns.length)
          expect(quotation_shipments.pluck(:trip_id)).to eq(shipment.charge_breakdowns.pluck(:trip_id))
        end
      end
    end

    context "with trucking" do
      let(:trucking) { {"pre_carriage" => {"trucking_time_in_seconds" => 100, "truck_type" => "default"}} }

      before do
        service.perform
      end

      it "creates a quotation and shipments" do
        aggregate_failures do
          expect(quotation_shipments.length).to eq(shipment.charge_breakdowns.length)
          expect(quotation_shipments.pluck(:trip_id)).to eq(shipment.charge_breakdowns.pluck(:trip_id))
        end
      end
    end

    context "with breakdowns" do
      let!(:pricings_metadatum) {
        FactoryBot.create(:pricings_metadatum,
          organization: shipment.organization,
          charge_breakdown: shipment.charge_breakdowns.first)
      }
      let(:other_metadata) {
        Pricings::Metadatum.where(organization: shipment.organization)
          .where.not(id: pricings_metadatum.id)
      }

      before do
        service.perform
      end

      it "creates a quotation and shipments" do
        aggregate_failures do
          expect(quotation_shipments.length).to eq(shipment.charge_breakdowns.length)
          expect(quotation_shipments.pluck(:trip_id)).to eq(shipment.charge_breakdowns.pluck(:trip_id))
          expect(other_metadata.map { |x| x.breakdowns.count }.uniq).to eq([pricings_metadatum.breakdowns.count])
        end
      end
    end

    context "with cargo" do
      let(:shipment) do
        FactoryBot.create(:complete_legacy_shipment,
          itinerary: itinerary,
          trip: trip,
          organization: organization,
          cargo_items: [],
          with_breakdown: true,
          with_tenders: true,
          with_aggregated_cargo: true)
      end

      before do
        FactoryBot.create(:legacy_cargo_item,
          payload_in_kg: 600,
          width: 0.15e3,
          length: 0.14e3,
          height: 0.16e3,
          quantity: 3,
          shipment: shipment)
        service.perform
      end

      it "creates a quotation and shipments" do
        aggregate_failures do
          expect(quotation_shipments.length).to eq(shipment.charge_breakdowns.length)
          expect(quotation_shipments.pluck(:trip_id)).to eq(shipment.charge_breakdowns.pluck(:trip_id))
        end
      end
    end

    context "with agg cargo" do
      let(:shipment) do
        FactoryBot.create(:complete_legacy_shipment,
          itinerary: itinerary,
          trip: trip,
          organization: organization,
          with_breakdown: true,
          with_tenders: true,
          with_aggregated_cargo: true)
      end

      before do
        service.perform
      end

      it "creates a quotation and shipments" do
        aggregate_failures do
          expect(quotation_shipments.length).to eq(shipment.charge_breakdowns.length)
          expect(quotation_shipments.pluck(:trip_id)).to eq(shipment.charge_breakdowns.pluck(:trip_id))
        end
      end
    end

    context "when sending email" do
      let(:send_email) { true }
      let(:result) { service.perform }

      before do
        mailer_double = double("mailer", deliver_later: true)
        allow(QuoteMailer).to receive(:quotation_admin_email).and_return(mailer_double)
      end

      it "creates a quotation and shipments" do
        aggregate_failures do
          expect(result).to be_truthy
          expect(quotation_shipments.length).to eq(shipment.charge_breakdowns.length)
          expect(quotation_shipments.pluck(:trip_id)).to eq(shipment.charge_breakdowns.pluck(:trip_id))
        end
      end
    end

    context "with existing quotation" do
      let!(:existing_quotation) {
        FactoryBot.create(:legacy_quotation,
          user: shipment.user,
          original_shipment_id: shipment.id)
      }

      before do
        service.perform
      end

      it "creates a quotation and shipments" do
        aggregate_failures do
          expect(quotation_shipments.length).to eq(shipment.charge_breakdowns.length)
          expect(quotation_shipments.pluck(:trip_id)).to eq(shipment.charge_breakdowns.pluck(:trip_id))
        end
      end
    end

    context "with outdated quotation" do
      let!(:existing_quotation) {
        FactoryBot.create(:legacy_quotation,
          user: shipment.user,
          original_shipment_id: shipment.id,
          updated_at: shipment.updated_at - 5.minutes)
      }

      before do
        service.perform
      end

      it "creates a quotation and shipments" do
        aggregate_failures do
          expect(quotation_shipments.length).to eq(shipment.charge_breakdowns.length)
          expect(quotation_shipments.pluck(:trip_id)).to eq(shipment.charge_breakdowns.pluck(:trip_id))
        end
      end
    end

    context "incorrect charge breakdowns" do
      let(:false_trip) {
        FactoryBot.create(:legacy_trip,
          itinerary: FactoryBot.create(:felixstowe_shanghai_itinerary, organization: shipment.organization))
      }

      before do
        FactoryBot.create(:legacy_charge_breakdown, shipment: shipment, trip: false_trip)
        service.perform
      end

      it "creates a quotation and shipments" do
        aggregate_failures do
          expect(quotation_shipments.length).to eq(1)
          expect(quotation_shipments.pluck(:trip_id)).to_not include(false_trip.id)
        end
      end
    end
  end
end