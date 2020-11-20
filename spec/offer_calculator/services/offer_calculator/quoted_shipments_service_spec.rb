# frozen_string_literal: true

require "rails_helper"
module OfferCalculator
  RSpec.describe QuotedShipmentsService, type: :service do
    let(:shipment) do
      FactoryBot.create(:complete_legacy_shipment,
        itinerary: itinerary,
        origin_hub: itinerary.origin_hub,
        destination_hub: itinerary.destination_hub,
        trip: trip,
        with_breakdown: true,
        with_tenders: true,
        organization: organization,
        trucking: trucking)
    end
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:send_email) { false }
    let(:trucking) { {} }
    let(:service) { described_class.new(shipment_id: shipment.id, send_email: send_email, mailer: "QuoteMailer") }
    let(:quotation) { Legacy::Quotation.find_by(original_shipment_id: shipment) }
    let(:quotation_shipments) { quotation.shipments }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }

    describe ".perform" do
      before do
        mailer = class_double("QuoteMailer").as_stubbed_const(transfer_nested_constants: true)
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        allow(mailer).to receive(:new_quotation_admin_email).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later)
      end

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
        let(:address) { FactoryBot.create(:gothenburg_address) }
        let(:trucking) {
          {"pre_carriage" => {"address_id" => address.id, "trucking_time_in_seconds" => 100, "truck_type" => "default"}}
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

      context "with breakdowns" do
        let!(:pricings_metadatum) do
          FactoryBot.create(:pricings_metadatum,
            organization: shipment.organization,
            charge_breakdown: shipment.charge_breakdowns.first)
        end

        let(:other_metadata) do
          Pricings::Metadatum.where(organization: shipment.organization)
            .where.not(id: pricings_metadatum.id)
        end

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

      context "with agg cargo" do
        let(:shipment) do
          FactoryBot.create(:complete_legacy_shipment,
            itinerary: itinerary,
            origin_hub: itinerary.origin_hub,
            destination_hub: itinerary.destination_hub,
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

        it "creates a quotation and shipments" do
          aggregate_failures do
            expect(result).to be_truthy
            expect(quotation_shipments.length).to eq(shipment.charge_breakdowns.length)
            expect(quotation_shipments.pluck(:trip_id)).to eq(shipment.charge_breakdowns.pluck(:trip_id))
          end
        end
      end

      context "with existing quotation" do
        before do
          FactoryBot.create(
            :legacy_quotation,
            user: shipment.user,
            original_shipment_id: shipment.id
          )

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
        before do
          FactoryBot.create(
            :legacy_quotation,
            user: shipment.user,
            original_shipment_id: shipment.id,
            updated_at: shipment.updated_at - 5.minutes
          )

          service.perform
        end

        it "creates a quotation and shipments" do
          aggregate_failures do
            expect(quotation_shipments.length).to eq(shipment.charge_breakdowns.length)
            expect(quotation_shipments.pluck(:trip_id)).to eq(shipment.charge_breakdowns.pluck(:trip_id))
          end
        end
      end

      context "with incorrect charge breakdowns" do
        let(:false_trip) do
          FactoryBot.create(:legacy_trip,
            itinerary: FactoryBot.create(:felixstowe_shanghai_itinerary, organization: shipment.organization))
        end

        before do
          FactoryBot.create(:legacy_charge_breakdown, shipment: shipment, trip: false_trip)
          service.perform
        end

        it "creates a quotation and shipments" do
          aggregate_failures do
            expect(quotation_shipments.length).to eq(1)
            expect(quotation_shipments.pluck(:trip_id)).not_to include(false_trip.id)
          end
        end
      end
    end
  end
end
