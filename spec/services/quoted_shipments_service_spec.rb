# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuotedShipmentsService, type: :service do
  let(:shipment) {
    FactoryBot.create(:complete_legacy_shipment,
      with_breakdown: true,
      with_tenders: true,
      trucking: trucking)
  }
  let(:send_email) { false }
  let(:trucking) { {} }
  let(:service) { described_class.new(shipment: shipment, send_email: send_email) }
  let(:quotation) { Legacy::Quotation.find_by(original_shipment_id: shipment) }
  let(:quotation_shipments) { quotation.shipments }

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

    context "with agg cargo" do
      let(:shipment) {
        FactoryBot.create(:complete_legacy_shipment,
          with_breakdown: true,
          with_tenders: true,
          with_aggregated_cargo: true)
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
  end
end
