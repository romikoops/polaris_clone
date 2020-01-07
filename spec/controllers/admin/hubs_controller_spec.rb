# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::HubsController, type: :controller do
  let(:tenant) { create(:tenant) }
  let!(:gothenburg) { FactoryBot.create(:gothenburg_hub, tenant: tenant) }
  let!(:user) { create(:user, tenant_id: tenant.id) }
  let!(:felixstowe) { create(:felixstowe_hub, tenant: tenant) }
  let!(:shanghai) { create(:shanghai_hub, tenant: tenant) }
  before(:each) do
    expect_any_instance_of(described_class).to receive(:require_authentication!).and_return(true)
    expect_any_instance_of(described_class).to receive(:require_non_guest_authentication!).and_return(true)
    expect_any_instance_of(described_class).to receive(:current_tenant).at_least(:once).and_return(tenant)
    expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(user)
  end

  describe 'GET #index' do
    it 'returns a response with paginated results' do
      get :index, params: { tenant_id: gothenburg.tenant.id, hub_type: gothenburg.hub_type, hub_status: gothenburg.hub_status }
      expect(response).to have_http_status(:success)
    end

    it 'returns a response with paginated results filtered by country' do
      params = {
        tenant_id: gothenburg.tenant.id,
        country: 'China',
        country_desc: true,
        name: 'Shanghai'
      }
      get :index, params: params
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.dig('data', 'hubsData').pluck('id')).to match_array([shanghai.id])
    end

    it 'returns a response with paginated results filtered by name' do
      params = {
        tenant_id: gothenburg.tenant.id,
        name_desc: true,
        name: 'Felixstowe'
      }
      get :index, params: params
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.dig('data', 'hubsData').pluck('id')).to match_array([felixstowe.id])
    end

    it 'returns a response with paginated results filtered by locode' do
      params = {
        tenant_id: gothenburg.tenant.id,
        locode_desc: true,
        locode: 'CNSHA'
      }
      get :index, params: params
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.dig('data', 'hubsData').pluck('id')).to match_array([shanghai.id])
    end

    it 'returns a response with paginated results filtered by type' do
      params = {
        tenant_id: gothenburg.tenant.id,
        type_desc: true,
        type: 'ocean'
      }
      get :index, params: params
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.dig('data', 'hubsData').pluck('id')).to match_array([felixstowe.id, gothenburg.id, shanghai.id])
    end
  end

  describe 'POST #upload' do
    context 'raises an error' do
      let(:errors_arr) do
        [{ row_no: 1, reason: 'A' },
         { row_no: 2, reason: 'B' },
         { row_no: 3, reason: 'C' },
         { row_no: 4, reason: 'D' }]
      end
      let(:error) { { has_errors: true, errors: errors_arr } }

      before do
        expect(Document).to receive(:create!)
        expect_any_instance_of(ExcelDataServices::Loaders::Uploader).to receive(:perform).and_return(error)
      end

      it 'returns error with messages when an error is raised' do
        post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: tenant.id }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
      end
    end
  end

  describe 'GET #download' do
    context 'unsuccesfully downloads' do
      let!(:hubs) { create(:gothenburg_hub, free_out: false, tenant: tenant, mandatory_charge: create(:mandatory_charge), nexus: create(:gothenburg_nexus)) }

      it 'returns error with messages when an error is raised' do
        get :download, params: { tenant_id: tenant.id }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'url').include?(tenant.subdomain)).to be_truthy
      end
    end
  end

  describe 'POST #set_status' do
    context 'sets the hub status to inactive' do
      it 'rsets the hub status to ' do
        post :set_status, params: { hub_id: gothenburg.id, tenant_id: tenant.id }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'data', 'hub_status')).to eq('inactive')
      end
    end
  end

  describe 'GET #show' do
    context 'returns the hub and related data' do
      it 'returns the correct hub and related data' do
        get :show, params: { id: gothenburg.id, tenant_id: tenant.id }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data').keys).to match_array(%w[hub routes relatedHubs schedules address mandatoryCharge])
      end
    end
  end

  describe 'POST #update_mandatory_charges' do
    let!(:desired_mandatory_charge) do
      create(:mandatory_charge,
             import_charges: true,
             export_charges: false,
             pre_carriage: false,
             on_carriage: false)
    end

    context 'sets the hub mandatory charge' do
      it 'sets the hub mandatory charge to the desired mandatory_charge' do
        params = {
          mandatoryCharge: {
            import_charges: true,
            export_charges: false,
            pre_carriage: false,
            on_carriage: false
          },
          id: gothenburg.id,
          tenant_id: tenant.id
        }
        post :update_mandatory_charges, params: params
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'hub', 'mandatory_charge_id')).to eq(desired_mandatory_charge.id)
      end
    end
  end
end
