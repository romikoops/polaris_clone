# frozen_string_literal: true

require "rails_helper"

module Shipments
  RSpec.describe ShipmentRequestCreator do
    describe "Mapping a legacy shipment to shipment request" do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:currency) { FactoryBot.create(:legacy_currency) }
      let(:user) { FactoryBot.create(:users_client, organization: organization) }
      let(:legacy_shipment) {
        FactoryBot.create(:complete_legacy_shipment, organization: organization, user: user, tender_id: tender.id)
      }
      let(:tender) { FactoryBot.create(:quotations_tender) }

      context "when creating a shipment request" do
        before do
          FactoryBot.create_list(:legacy_file, 2, :with_file, shipment: legacy_shipment, organization: organization)
        end

        let(:creator) { described_class.new(legacy_shipment: legacy_shipment, user: user) }
        let(:shipment_request) { creator.create.shipment_request }

        it "creates a valid shipment request" do
          aggregate_failures do
            expect(shipment_request).to be_valid
            expect(shipment_request).to be_persisted
          end
        end

        it "associates to the chosen tender" do
          aggregate_failures do
            expect(shipment_request.tender).to be_present
            expect(shipment_request.tender.origin_hub.hub_code).to eq(legacy_shipment.origin_hub.hub_code)
            expect(shipment_request.tender.destination_hub.hub_code).to eq(legacy_shipment.destination_hub.hub_code)
          end
        end

        it "attaches documents to the shipment request" do
          aggregate_failures do
            expect(shipment_request.documents.count).to eq 2
            expect(shipment_request.documents[0]).to be_persisted
            expect(shipment_request.documents[1]).to be_persisted
            expect(
              shipment_request.documents.map { |doc| doc.file.blob }
            ).to match_array(Legacy::File.where(shipment: legacy_shipment).map { |doc| doc.file.blob })
          end
        end

        it "creates the consignee and consignor" do
          aggregate_failures do
            expect(shipment_request.consignor).to be_persisted
            expect(shipment_request.consignee).to be_persisted
          end
        end

        it "creates the notifyees" do
          expect(shipment_request.notifyees.count).to eq 2
        end

        it "maps contacts correctly" do
          consignee = shipment_request.consignee.contact
          legacy_consignee = legacy_shipment.shipment_contacts.find_by(contact_type: "consignee").contact
          aggregate_failures do
            expect(consignee.user_id).to eql Users::Client.unscoped.find(legacy_consignee.user_id).id
            expect(consignee.company_name).to eql legacy_consignee.company_name
            expect(consignee.first_name).to eql legacy_consignee.first_name
            expect(consignee.last_name).to eql legacy_consignee.last_name
            expect(consignee.phone).to eql legacy_consignee.phone
            expect(consignee.email).to eql legacy_consignee.email
            expect(consignee.geocoded_address).to eql legacy_consignee.address.geocoded_address
            expect(consignee.street).to eql legacy_consignee.address.street
            expect(consignee.street_number).to eql legacy_consignee.address.street_number
            expect(consignee.province).to eql legacy_consignee.address.province
            expect(consignee.city).to eql legacy_consignee.address.city
            expect(consignee.premise).to eql legacy_consignee.address.premise
            expect(consignee.postal_code).to eql legacy_consignee.address.zip_code
            expect(consignee.country_code).to eql legacy_consignee.address.country.code
          end
        end
      end
    end
  end
end
