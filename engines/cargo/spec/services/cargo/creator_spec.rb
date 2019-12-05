# frozen_string_literal: true

require 'rails_helper'

module Cargo
  RSpec.describe Creator, type: :model do
    describe 'Mapping legacy cargo to cargo' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:currency) { FactoryBot.create(:legacy_currency) }
      let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
      let(:tender) { FactoryBot.create(:quotations_tender) }

      context 'When shipment is FCL' do
        let(:fcl_legacy_shipment) { FactoryBot.create(:complete_legacy_shipment, load_type: :container, tenant: tenant, user: user, meta: { tender_id: tender.id }) }
        let!(:fcl_20_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment: fcl_legacy_shipment) }
        let!(:fcl_40_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_40', shipment: fcl_legacy_shipment) }
        let!(:creator) { described_class.new(legacy_shipment: fcl_legacy_shipment).perform }

        it 'creates a valid FCL cargo' do
          cargo = ::Cargo::Cargo.find_by(quotation_id: tender.quotation_id)
          expect(cargo).to be_persisted
          expect(cargo.units.count).to eq 3
        end
      end

      context 'When shipment is LCL' do
        let(:lcl_legacy_shipment) { FactoryBot.create(:complete_legacy_shipment, load_type: :cargo_item, tenant: tenant, user: user, meta: { tender_id: tender.id }) }
        let!(:creator) { described_class.new(legacy_shipment: lcl_legacy_shipment).perform }

        it 'creates a valid LCL cargo' do
          cargo = ::Cargo::Cargo.find_by(quotation_id: tender.quotation_id)
          expect(cargo).to be_persisted
          expect(cargo.units.count).to eq 1
        end
      end

      context 'When shipment is aggregated cargo' do
        let(:aggregated_legacy_shipment) { FactoryBot.create(:complete_legacy_shipment, load_type: :cargo_item, with_aggregated_cargo: true, tenant: tenant, user: user, meta: { tender_id: tender.id }) }
        let!(:creator) { described_class.new(legacy_shipment: aggregated_legacy_shipment).perform }

        it 'creates a valid aggregated cargo' do
          cargo = ::Cargo::Cargo.find_by(quotation_id: tender.quotation_id)
          expect(cargo).to be_persisted
          expect(cargo.units.count).to eq 1
          expect(cargo.units.first.cargo_type).to eq('AGR')
        end
      end

      context 'When cargo has errors' do
        before do
          tender.quotation.update_column(:tenant_id, nil)
        end

        let(:shipment) { FactoryBot.create(:complete_legacy_shipment, meta: { tender_id: tender.id }) }
        let!(:creator) { described_class.new(legacy_shipment: shipment).perform }

        it 'does not create cargo' do
          expect(Cargo.count).to be_zero
          expect(creator.errors).to be_present
        end
      end

      context 'When no cargo units' do
        let(:shipment) { FactoryBot.build(:complete_legacy_shipment, meta: { tender_id: tender.id }) }
        let!(:creator) { described_class.new(legacy_shipment: shipment).perform }
        it 'does not create cargo' do
          expect(Cargo.count).to be_zero
          expect(creator.errors).to be_present
        end
      end
    end
  end
end
