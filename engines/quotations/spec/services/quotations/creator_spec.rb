# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Quotations::Creator do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:legacy_user) { FactoryBot.create(:legacy_user) }
  let(:origin_nexus) { FactoryBot.create(:legacy_nexus, tenant: legacy_tenant) }
  let(:destination_nexus) { FactoryBot.create(:legacy_nexus, tenant: legacy_tenant)}
  let(:bas_charge) { FactoryBot.create(:legacy_charge_categories, :bas) }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, :default, tenant: legacy_tenant, name: 'Gothenburg - Shanghai') }
  let(:origin_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, tenant: legacy_tenant, nexus: origin_nexus) }
  let(:destination_hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, tenant: legacy_tenant, nexus: destination_nexus) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'express', tenant: legacy_tenant) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, tenant: legacy_tenant) }
  let(:charge_breakdown) { FactoryBot.create(:legacy_charge_breakdown, shipment: shipment) }
  let(:charge) { charge_breakdown.grand_total }
  let(:target_charge) { Legacy::ChargeCategory.find_by(code: 'bas', tenant: legacy_tenant)}
  let(:meta) do
     {
        load_type: 'container',
        mode_of_transport: 'ocean',
        name: itinerary.name,
        carrier_name: 'Maersk',
        origin_hub: origin_hub,
        destination_hub: destination_hub,
        itinerary_id: itinerary.id,
        tenant_vehicle_id: tenant_vehicle.id
      }
  end

  describe '#perform' do
    subject { described_class.new(charge: charge, meta: meta, user: legacy_user) }
    before { Tenants::Tenant.create(legacy: legacy_tenant) }

    context 'creating quotations' do
      it 'creates a single quotation for a user per input object received' do
        aggregate_failures do
          expect { subject.perform }.to change { Quotations::Quotation.count }.by(1)
          expect(Quotations::Quotation.find_by_user_id(legacy_user.id)).not_to be_nil
        end
      end
    end

    context 'creating tenders for a quotation' do
      it 'creates tenders belonging to a particular quotation from the input received' do
        expect { subject.perform }.to change { Quotations::Tender.count }.by(1)
        quotation_tender = Quotations::Tender.first
        %i(load_type tenant_vehicle_id name quotation_id).each do |key|
          expect(quotation_tender[key]).not_to be_nil
        end
      end
    end

    context 'creating line items for quotation tenders' do
      it 'creates line_items (for tenders) from the different entries in the quote object' do
        aggregate_failures do
          expect { subject.perform }.to change { Quotations::LineItem.count }.by(1)
          line_item = Quotations::LineItem.find_by(charge_category_id: target_charge.id)
          expect(line_item.tender_id).not_to be_nil
          expect(line_item.tender.quotation).not_to be_nil
          expect(line_item.amount).not_to be_nil
        end
      end
    end
  end
end
