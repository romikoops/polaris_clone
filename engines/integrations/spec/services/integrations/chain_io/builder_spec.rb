# frozen_string_literal: true

require 'rails_helper'

module Integrations
  module ChainIo
    RSpec.describe Builder do
      describe 'Preparing the json for chain.io' do
        let(:tenant) { FactoryBot.create(:legacy_tenant) }
        let!(:tenants_tenant) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
        let(:currency) { FactoryBot.create(:legacy_currency) }
        let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
        let(:tender) { FactoryBot.create(:quotations_tender) }
        let(:fcl_legacy_shipment) { FactoryBot.create(:complete_legacy_shipment, tenant: tenant, user: user, meta: { tender_id: tender.id }) }
        let(:shipment_request_creator) { ::Shipments::ShipmentRequestCreator.new(legacy_shipment: fcl_legacy_shipment, user: user, sandbox: nil) }
        let(:shipment_request) { shipment_request_creator.create.shipment_request }
        let!(:cargo) {
          FactoryBot.create(:cargo_cargo,
                            quotation_id: tender.quotation_id,
                            units:
                              FactoryBot.create_list(:fcl_20_unit, 2, weight_value: 3000, volume_value: 1.3).concat(
                                FactoryBot.create_list(:lcl_unit, 2)
                              ))
        }
        let(:shipment_request) { shipment_request_creator.create.shipment_request }
        let!(:fcl_20_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment: fcl_legacy_shipment) }
        let!(:fcl_40_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_40', shipment: fcl_legacy_shipment) }
        let(:data) { Builder.new(shipment_request_id: shipment_request.id).prepare }
        let(:shipment_request_decorator) { ShipmentRequest.find(shipment_request.id) }
        let(:json_shipment) { data[:shipments].first }

        it 'builds a json with the correct schema' do
          expect(json_shipment).to be_present
          expect(json_shipment).to match_response_schema('shipment')
        end

        it 'builds a json with the correct values' do
          expect(json_shipment['lading_port']).to match(unlocode: '', description: 'Gothenburg, SE')
          expect(json_shipment['departure_estimated']).to match shipment_request_decorator.etd
          expect(json_shipment['arrival_port']).to match(unlocode: '', description: 'Gothenburg, SE')
          expect(json_shipment['arrival_port_estimated']).to match shipment_request_decorator.eta
          expect(json_shipment['freight_payment_terms']).to match 'Collect'
          expect(json_shipment['inco_term']).to match shipment_request_decorator.incoterm_text
          expect(json_shipment['consignee']).to match Contact.new(shipment_request_decorator.consignee.contact).format
          expect(json_shipment['consignor']).to match Contact.new(shipment_request_decorator.consignor.contact).format
          expect(json_shipment['containerization_type']).to match shipment_request_decorator.tender.quotation.cargo.containerization_type
          expect(json_shipment['containers']).to match [{ container_number: '', delivery_mode: '', size_code: '20GP', type_code: '20GP' },
                                                        { container_number: '', delivery_mode: '', size_code: '20GP', type_code: '20GP' }]
          expect(json_shipment['created_by']).to match shipment_request_decorator.created_by
          expect(json_shipment['transport_mode']).to match shipment_request_decorator.tender.origin_hub.hub_type
          expect(json_shipment['package_group']).to match [{ description_of_goods: '', gross_weight_kgs: '6000.0', package_quantity: 2, volume_cbms: '1.344' },
                                                           { description_of_goods: '', gross_weight_kgs: '6000.0', package_quantity: 2, volume_cbms: '1.344' }]
        end
      end
    end
  end
end
