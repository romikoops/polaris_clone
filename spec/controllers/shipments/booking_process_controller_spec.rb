# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shipments::BookingProcessController do
  let(:shipment) { create(:complete_legacy_shipment, with_breakdown: true) }
  let(:user) { create(:legacy_user, tenant: shipment.tenant) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
  end

  describe 'GET #download_shipment' do
    it 'returns an http status of success' do
      get :download_shipment, params: { tenant_id: shipment.tenant, shipment_id: shipment.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response.dig('data', 'key')).to eq('shipment_recap')
        expect(json_response.dig('data', 'url')).to include("shipment_#{shipment.imc_reference}.pdf?disposition=attachment")
      end
    end
  end
end
