# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Quotations::Creator do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:legacy_user) { FactoryBot.create(:legacy_user) }
  let(:origin_nexus) { FactoryBot.create(:legacy_nexus, tenant: legacy_tenant) }
  let(:destination_nexus) { FactoryBot.create(:legacy_nexus, tenant: legacy_tenant) }
  let(:bas_charge) { FactoryBot.create(:legacy_charge_categories, :bas) }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, :default, tenant: legacy_tenant, name: 'Gothenburg - Shanghai') }
  let(:origin_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, tenant: legacy_tenant, nexus: origin_nexus) }
  let(:destination_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, tenant: legacy_tenant, nexus: destination_nexus) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'express', tenant: legacy_tenant) }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slow', tenant: legacy_tenant) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, tenant: legacy_tenant) }
  let(:charge_breakdown) { FactoryBot.create(:legacy_charge_breakdown, shipment: shipment) }
  let(:charge) { charge_breakdown.grand_total }
  let(:charge_breakdown_2) { FactoryBot.create(:legacy_charge_breakdown, shipment: shipment) }
  let(:charge_2) { charge_breakdown.grand_total }
  let(:target_charge) { Legacy::ChargeCategory.find_by(code: 'bas', tenant: legacy_tenant) }
  let(:trip_1) { FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }
  let(:trip_2) { FactoryBot.create(:legacy_trip, itinerary: itinerary, tenant_vehicle: tenant_vehicle_2) }
  let(:results) do
    [
      {
        total: charge,
        schedules: [Legacy::Schedule.from_trip(trip_1)]
      },
      {
        total: charge_2,
        schedules: [Legacy::Schedule.from_trip(trip_2)]
      }
    ]
  end

  describe '#perform' do
    let!(:klass) { described_class.new(results: results, user: legacy_user) }
    let(:result) { klass.perform }

    before { Tenants::Tenant.create(legacy: legacy_tenant) }

    context 'when creating quotations' do
      it 'creates a single quotation for a user per input object received' do
        aggregate_failures do
          expect(result).to be_a(Quotations::Quotation)
          expect(result.tenders.count).to eq(2)
        end
      end
    end

    context 'when creating tenders for a quotation' do
      it 'creates tenders belonging to a particular quotation from the input received' do
        aggregate_failures do
          expect { klass.perform }.to change { Quotations::Tender.count }.by(2)
          quotation_tender = Quotations::Tender.first
          %i[load_type tenant_vehicle_id name quotation_id].each do |key|
            expect(quotation_tender[key]).not_to be_nil
          end
        end
      end
    end

    context 'when creating line items for quotation tenders' do
      it 'creates line_items (for tenders) from the different entries in the quote object' do
        aggregate_failures do
          expect { klass.perform }.to change { Quotations::LineItem.count }.by(2)
          line_item = Quotations::LineItem.find_by(charge_category_id: target_charge.id)
          expect(line_item.tender_id).not_to be_nil
          expect(line_item.tender.quotation).not_to be_nil
          expect(line_item.amount).not_to be_nil
          expect(line_item.cargo).to eq(shipment.cargo_units.first)
        end
      end
    end
  end
end
