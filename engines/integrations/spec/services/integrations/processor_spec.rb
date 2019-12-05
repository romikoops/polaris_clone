# frozen_string_literal: true

require 'rails_helper'

module Integrations
  RSpec.describe Processor do
    let(:shipment_request_id) { '123' }

    let(:tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenants_tenant) { FactoryBot.create(:tenants_tenant, legacy: tenant) }

    context 'when chain.io integration is enabled for the tenant' do
      let!(:scope) {
        FactoryBot.create(:tenants_scope, target: tenants_tenant,
                                          content: {
                                            integrations: {
                                              chainio: {
                                                flow_id: 'test_flow_id',
                                                api_key: 'test_api_key'
                                              }
                                            }
                                          })
      }

      it 'processes the chain_io integration' do
        expect(ChainIo::Processor).to receive(:process).with(shipment_request_id: shipment_request_id, tenant_id: tenants_tenant.id)

        Processor.process(shipment_request_id: shipment_request_id, tenant_id: tenants_tenant.id)
      end
    end

    context 'when chain.io integration is disabled for the tenant' do
      let!(:scope) {
        FactoryBot.create(:tenants_scope, target: tenants_tenant,
                                          content: {
                                            integrations: {
                                              chainio: {
                                                flow_id: '',
                                                api_key: ''
                                              }
                                            }
                                          })
      }

      it 'does not process the chain_io integration' do
        allow(ChainIo::Processor).to receive(:process).with(shipment_request_id: shipment_request_id, tenant_id: tenants_tenant.id)

        Processor.process(shipment_request_id: shipment_request_id, tenant_id: tenants_tenant.id)

        expect(ChainIo::Processor).not_to have_received(:process)
      end
    end
  end
end
