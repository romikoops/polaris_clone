# frozen_string_literal: true

require 'rails_helper'

module Cargo
  RSpec.describe Creator, type: :model do
    describe 'Mapping legacy cargo to cargo' do
      let(:tender) { FactoryBot.create(:quotations_tender) }
      let(:cargo) { ::Cargo::Cargo.find_by(quotation_id: tender.quotation_id) }
      let(:legacy_shipment) { FactoryBot.create(:complete_legacy_shipment, load_type: load_type, meta: { tender_id: tender.id }) }

      context 'when shipment is FCL' do
        let(:load_type) { :container }

        before do
          FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment: legacy_shipment)
          FactoryBot.create(:legacy_container, cargo_class: 'fcl_40', shipment: legacy_shipment)
          described_class.new(legacy_shipment: legacy_shipment).perform
        end

        it 'creates a valid FCL cargo' do
          aggregate_failures do
            expect(cargo).to be_persisted
            expect(cargo.units.count).to eq 3
          end
        end
      end

      context 'when shipment is LCL' do
        let(:load_type) { :cargo_item }

        before do
          described_class.new(legacy_shipment: legacy_shipment).perform
        end

        it 'creates a valid LCL cargo' do
          aggregate_failures do
            expect(cargo).to be_persisted
            expect(cargo.units.count).to eq 1
          end
        end
      end

      context 'when shipment is aggregated cargo' do
        let(:aggregated_legacy_shipment) { FactoryBot.create(:complete_legacy_shipment, load_type: :cargo_item, with_aggregated_cargo: true, meta: { tender_id: tender.id }) }

        before { described_class.new(legacy_shipment: aggregated_legacy_shipment).perform }

        it 'creates a valid aggregated cargo' do
          aggregate_failures do
            expect(cargo).to be_persisted
            expect(cargo.units.count).to eq 1
            expect(cargo.units.first.cargo_type).to eq('AGR')
          end
        end
      end

      context 'when no cargo units' do
        let(:shipment) { FactoryBot.build(:complete_legacy_shipment, meta: { tender_id: tender.id }) }
        let(:creator) { described_class.new(legacy_shipment: shipment).perform }

        it 'does not create cargo' do
          aggregate_failures do
            expect(::Cargo::Cargo.count).to be_zero
            expect(creator.errors).to be_present
          end
        end
      end
    end
  end
end
