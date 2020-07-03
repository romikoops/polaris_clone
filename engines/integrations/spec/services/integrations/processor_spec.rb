# frozen_string_literal: true

require 'rails_helper'

module Integrations
  RSpec.describe Processor do
    let(:shipment_request_id) { '123' }
    let(:organization) { FactoryBot.create(:organizations_organization) }

    context 'when chain.io integration is enabled for the organization' do
      let!(:scope) {
        FactoryBot.create(:organizations_scope, target: organization,
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
        expect(ChainIo::Processor).to receive(:process).with(shipment_request_id: shipment_request_id, organization_id: organization.id)

        Processor.process(shipment_request_id: shipment_request_id, organization_id: organization.id)
      end
    end

    context 'when chain.io integration is disabled for the organization' do
      let!(:scope) {
        FactoryBot.create(:organizations_scope, target: organization,
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
        allow(ChainIo::Processor).to receive(:process).with(shipment_request_id: shipment_request_id, organization_id: organization.id)

        Processor.process(shipment_request_id: shipment_request_id, organization_id: organization.id)

        expect(ChainIo::Processor).not_to have_received(:process)
      end
    end
  end
end
