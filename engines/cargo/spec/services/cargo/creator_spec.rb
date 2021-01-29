# frozen_string_literal: true

require "rails_helper"

module Cargo
  RSpec.describe Creator, type: :model do
    describe "Mapping legacy cargo to cargo" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:user) { FactoryBot.create(:users_client, organization: organization) }
      let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }
      let(:tender) { FactoryBot.create(:quotations_tender, quotation: quotation) }
      let(:cargo) { ::Cargo::Cargo.find_by(quotation_id: tender.quotation_id) }
      let(:load_type) { :container }
      let(:shipment) { FactoryBot.create(:complete_legacy_shipment, organization: organization, load_type: load_type) }
      let(:creator) { described_class.new(legacy_shipment: shipment, quotation: quotation) }

      context "when shipment is FCL" do
        before do
          FactoryBot.create(:legacy_container, cargo_class: "fcl_20", shipment: shipment)
          FactoryBot.create(:legacy_container, cargo_class: "fcl_40", shipment: shipment)
          described_class.new(legacy_shipment: shipment, quotation: quotation).perform
        end

        it "creates a valid FCL cargo" do
          aggregate_failures do
            expect(cargo).to be_persisted
            expect(cargo.units.count).to eq 3
          end
        end
      end

      context "when shipment is LCL" do
        let(:load_type) { :cargo_item }

        before do
          described_class.new(legacy_shipment: shipment, quotation: quotation).perform
        end

        it "creates a valid LCL cargo" do
          aggregate_failures do
            expect(cargo).to be_persisted
            expect(cargo.units.count).to eq 1
          end
        end
      end

      context "when shipment is aggregated cargo" do
        let(:shipment) {
          FactoryBot.create(:complete_legacy_shipment,
            load_type: :cargo_item, with_aggregated_cargo: true, organization: organization, user: user)
        }

        before { creator.perform }

        it "creates a valid aggregated cargo" do
          aggregate_failures do
            expect(cargo).to be_persisted
            expect(cargo.units.count).to eq 1
            expect(cargo.units.first.cargo_type).to eq("AGR")
          end
        end
      end

      context "when no cargo units" do
        before do
          allow(creator).to receive(:containers).and_return(Legacy::Container.none)
        end

        it "does not create cargo" do
          aggregate_failures do
            expect { creator.perform }.to raise_error(Creator::EmptyCargo)
            expect(::Cargo::Cargo.count).to be_zero
          end
        end
      end

      context "when invalid cargo" do
        before do
          shipment.containers.update_all(payload_in_kg: -10)
        end

        let(:cargo) { FactoryBot.create(:cargo_cargo, quotation_id: quotation.id) }

        it "does not create cargo" do
          expect { creator.perform }.to raise_error(Creator::InvalidCargo)
        end
      end
    end
  end
end
