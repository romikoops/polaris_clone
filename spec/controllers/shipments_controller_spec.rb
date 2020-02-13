# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShipmentsController do
  let(:tenant) { create(:tenant) }
  let(:shipment) { create(:shipment, tenant: tenant, user: user) }
  let(:user) { create(:user, tenant: tenant) }
  let(:json_response) { JSON.parse(response.body) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns an http status of success' do
      get :index, params: { tenant_id: tenant.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'Patch #update_user' do
    before do
      patch :update_user, params: { tenant_id: tenant.id, id: shipment.id }
      shipment.reload
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'updates the shipment user' do
      expect(shipment.user_id).to eq(user.id)
    end
  end

  describe 'POST #upload_document' do
    before do
      post :upload_document, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../test_sheets/spec_sheet.xlsx', __dir__)), shipment_id: shipment.id, tenant_id: tenant.id, type: 'packing_sheet' }
    end

    it 'returns the document with the signed url' do
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response['data']).not_to be_empty
        expect(json_response.dig('data', 'signed_url')).to be_truthy
      end
    end
  end
end
