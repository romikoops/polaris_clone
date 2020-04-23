# frozen_string_literal: true

require 'rails_helper'

module Integrations
  module ChainIo
    RSpec.describe Builder do
      describe 'Preparing the json for chain.io' do
        let(:tenant) { FactoryBot.create(:legacy_tenant) }
        let(:currency) { FactoryBot.create(:legacy_currency) }
        let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
        let(:profile) { FactoryBot.create(:profiles_profile) }
        let(:tender) { FactoryBot.create(:quotations_tender) }
        let(:fcl_legacy_shipment) { FactoryBot.create(:complete_legacy_shipment, tenant: tenant, user: user, meta: { tender_id: tender.id }, tender_id: tender.id) }
        let(:shipment_request_creator) { ::Shipments::ShipmentRequestCreator.new(legacy_shipment: fcl_legacy_shipment, user: user, sandbox: nil) }
        let(:shipment_request) { shipment_request_creator.create.shipment_request }
        let(:data) { described_class.new(shipment_request_id: shipment_request.id).prepare }
        let(:shipment_request_decorator) { ShipmentRequest.find(shipment_request.id) }
        let(:json_shipment) { data[:shipments].first }

        before do
          FactoryBot.create(:legacy_charge_breakdown, shipment: fcl_legacy_shipment, tender_id: tender.id)
          allow(Profiles::ProfileService).to receive(:fetch).and_return(Profiles::ProfileDecorator.new(profile))
          FactoryBot.create(:tenants_tenant, legacy: tenant)
          FactoryBot.create(:cargo_cargo,
                            quotation_id: tender.quotation_id,
                            units:
                              FactoryBot.create_list(:fcl_20_unit, 2, weight_value: 3000, volume_value: 1.3).concat(
                                FactoryBot.create_list(:lcl_unit, 2)
                              ))
          FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment: fcl_legacy_shipment)
          FactoryBot.create(:legacy_container, cargo_class: 'fcl_40', shipment: fcl_legacy_shipment)
        end

        context 'with a standard shipment' do
          it 'builds a json with the correct schema' do
            expect(data).to match_response_schema('shipment')
          end

          it 'has the correct lading port' do
            expect(json_shipment['lading_port']).to match(unlocode: '', description: 'Gothenburg, SE')
          end

          it 'has the correct departure estimated date' do
            expect(json_shipment['departure_estimated']).to match shipment_request_decorator.etd
          end

          it 'has the correct arrival port' do
            expect(json_shipment['arrival_port']).to match(unlocode: '', description: 'Gothenburg, SE')
          end

          it 'has the correct arrival port estimated date' do
            expect(json_shipment['arrival_port_estimated']).to match shipment_request_decorator.eta
          end

          it 'has the correct freight freight payment terms' do
            expect(json_shipment['freight_payment_terms']).to match 'Collect'
          end

          it 'has the correct inco terms' do
            expect(json_shipment['inco_term']).to match shipment_request_decorator.incoterm_text
          end

          it 'has the correct consignee' do
            expect(json_shipment['consignee']).to match Contact.new(shipment_request_decorator.consignee.contact).format
          end

          it 'has the correct consignor' do
            expect(json_shipment['consignor']).to match Contact.new(shipment_request_decorator.consignor.contact).format
          end

          it 'has the correct containerization type' do
            expect(json_shipment['containerization_type']).to match shipment_request_decorator.tender.quotation.cargo.containerization_type
          end

          it 'has the correct containers' do
            expect(json_shipment['containers']).to match [{ container_number: '', delivery_mode: '', size_code: '22GP', type_code: '22GP' },
                                                          { container_number: '', delivery_mode: '', size_code: '22GP', type_code: '22GP' }]
          end

          it 'has the correct created_by date' do
            expect(json_shipment['created_by']).to match shipment_request_decorator.created_by
          end

          it 'has the correct transport mode' do
            expect(json_shipment['transport_mode']).to match shipment_request_decorator.tender.origin_hub.hub_type
          end

          it 'has the correct package group' do
            expect(json_shipment['package_group']).to match [{ description_of_goods: '', gross_weight_kgs: '6000.0', package_quantity: 2, volume_cbms: '1.344' },
                                                             { description_of_goods: '', gross_weight_kgs: '6000.0', package_quantity: 2, volume_cbms: '1.344' }]
          end
        end

        context 'with no notifyee' do
          let(:no_notifyee_shipment) { FactoryBot.create(:legacy_shipment_without_notifyee, tenant: tenant, user: user, meta: { tender_id: tender.id }, tender_id: tender.id) }
          let(:shipment_request_creator) { ::Shipments::ShipmentRequestCreator.new(legacy_shipment: no_notifyee_shipment, user: user, sandbox: nil) }
          let(:shipment_request) { shipment_request_creator.create.shipment_request }
          let(:data) { described_class.new(shipment_request_id: shipment_request.id).prepare }
          let(:shipment_request_decorator) { ShipmentRequest.find(shipment_request.id) }
          let(:json_shipment) { data[:shipments].first }

          it 'returns nil for a notifyee party' do
            expect(json_shipment['notify_party']).to match({})
          end
        end

        context 'with cargo items' do
          let!(:shipment_cargo_item) { FactoryBot.create(:legacy_cargo_item, shipment: fcl_legacy_shipment) }

          it 'properly sends cargo unit chargeable weight' do
            expect(json_shipment['chargeable_weight']).to match(shipment_cargo_item.chargeable_weight)
          end

          it 'properly calculates cargo unit dimensional weight' do
            expect(json_shipment['dimensional_weight']).to match(8)
          end
        end
      end
    end
  end
end
