# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ShipmentsController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:user) { create(:legacy_user, tenant: tenant, email: 'user@itsmycargo.com', role: role) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let!(:role) { create(:role, name: 'shipper') }
  let(:shipment) { FactoryBot.create(:shipment, with_breakdown: true) }
  let(:charge_breakdown) { shipment.charge_breakdowns.selected }
  let(:breakdown) { FactoryBot.build(:pricings_breakdown) }
  let(:user_breakdown) { FactoryBot.build(:pricings_breakdown, target: tenants_user) }
  let(:parsed_response) { JSON.parse(response.body) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns an http status of success' do
      get :index, params: { tenant_id: tenant }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    before do
      allow(controller).to receive(:append_info_to_payload).and_return(true)
      allow(Pricings::Metadatum).to receive(:find_by).and_return(instance_double('Pricings::Metadatum', breakdowns: [breakdown, user_breakdown]))
    end

    context 'with charge breakdowns' do
      before do
        allow(shipment).to receive(:selected_offer).and_return({})
        allow(shipment).to receive('charge_breakdowns').and_return(object_double(selected: charge_breakdown))
        get :show, params: { id: shipment.id, tenant_id: tenant.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the shipment object sent in the parameters' do
        aggregate_failures do
          expect(parsed_response['data']['shipment']['id']).to eq(shipment.id)
          expect(parsed_response['data'].keys).to match_array(%w[shipment cargoItems containers aggregatedCargo contacts documents addresses cargoItemTypes accountHolder pricingBreakdowns])
        end
      end
    end

    context 'without charge breakdowns' do
      before do
        allow(shipment).to receive(:selected_offer).and_return({})
        allow(shipment).to receive('charge_breakdowns').and_return(object_double(selected: {}))
        get :show, params: { id: shipment.id, tenant_id: tenant.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the shipment object sent in the parameters' do
        aggregate_failures do
          expect(parsed_response['data']['shipment']['id']).to eq(shipment.id)
          expect(parsed_response['data'].keys).to match_array(%w[shipment cargoItems containers aggregatedCargo contacts documents addresses cargoItemTypes accountHolder pricingBreakdowns])
        end
      end
    end
  end

  describe 'POST #upload_client_document' do
    before do
      post :upload_client_document, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), shipment_id: shipment.id, tenant_id: tenant.id, type: 'packing_sheet' }
    end

    it 'returns the document with the signed url' do
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(parsed_response.dig('data', 'signed_url')).to be_truthy
      end
    end
  end

  describe 'POST #document_action' do
    let(:file) { FactoryBot.create(:legacy_file, shipment: shipment) }

    before do
      post :document_action, params: { id: file.id, shipment_id: shipment.id, tenant_id: tenant.id, type: 'approve' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns approves the document and returns it' do
      aggregate_failures do
        expect(parsed_response['data']).not_to be_empty
        expect(parsed_response.dig('data', 'approved')).to eq('approved')
      end
    end
  end

  describe 'POST #document_delete' do
    let(:file) { FactoryBot.create(:legacy_file, shipment: shipment) }

    it 'deletes the document' do
      post :document_delete, params: { id: file.id, shipment_id: shipment.id, tenant_id: tenant.id }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(Legacy::File.find_by(id: file.id)).to be_nil
      end
    end
  end
end
