# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/request_spec_helpers'

describe 'Shipment requests', type: :request do

  # cargo_item or container

  context 'user logged in' do
    include_context 'logged_in'

    let(:shipment) { create(:shipment) }
    it 'Writes an empty shipment to the DB' do
      post subdomain_shipments_path(subdomain_id: 'demo'), params: { details: { loadType: 'container', direction: 'import' }}
      expect(response).to have_http_status(:success)
      expect(json[:success]).to be_truthy
      expect(json[:data]).to match({ message: 'Health check pinged successfully.' })
    end

    it 'Retrieves the shipment data required for the next step in the booking proccess.' do
      post subdomain_shipment_get_offer_path(subdomain_id: 'demo', shipment_id: shipment.id), params: { shipment: { planned_pickup_date: 'container', direction: 'import' }}

      get_offer
    end
  end
end
