# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::LocalChargesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:tenant) { FactoryBot.create(:tenant) }

  before do
    allow(controller).to receive(:require_authentication!).and_return(true)
    allow(controller).to receive(:require_non_guest_authentication!).and_return(true)
    allow(controller).to receive(:current_tenant).at_least(:once).and_return(tenant)
    allow(controller).to receive(:current_user).at_least(:once).and_return(user)
  end

  describe 'GET #index' do
    before do
      create(:legacy_local_charge,
             tenant: tenant,
             effective_date: Date.parse('Thu, 24 Jan 2019'),
             expiration_date: Date.parse('Fri, 24 Jan 2020'))
    end

    it 'returns an http status of success' do
      get :index, params: { tenant_id: tenant.id }
      expect(response).to have_http_status(:success)
    end

    it 'returns the correct data given the params' do
      get :index, params: { tenant_id: tenant.id, per_page: 10, name_desc: 'true' }
      json_response = JSON.parse(response.body)
      expect(json_response.dig('data', 'localChargeData', 0, 'id')).to eq(::Legacy::LocalCharge.first.id)
    end
  end

  describe 'POST #edit' do
    let(:local_charge) do
      create(:legacy_local_charge,
             tenant: tenant,
             effective_date: Date.parse('Thu, 24 Jan 2019'),
             expiration_date: Date.parse('Fri, 24 Jan 2020'))
    end
    let(:fees) { { 'ABC' => 123 } }

    it 'edits the fees correctly' do
      post :edit, params: { tenant_id: tenant.id, id: local_charge.id, data: { id: local_charge.id, fees: fees } }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(local_charge.reload.fees.values.first.to_i).to eq(fees.values.first)
      end
    end
  end

  describe 'POST #upload' do
    context 'with errors' do
      let(:errors_arr) do
        [{ row_no: 1, reason: 'A' },
         { row_no: 2, reason: 'B' },
         { row_no: 3, reason: 'C' },
         { row_no: 4, reason: 'D' }]
      end
      let(:error) { { has_errors: true, errors: errors_arr } }

      before do
        allow(Legacy::File).to receive(:create!)
        excel_service = instance_double('ExcelDataServices::Loaders::Uploader')
        allow(ExcelDataServices::Loaders::Uploader).to receive(:new).and_return(excel_service)
        allow(excel_service).to receive(:perform).and_return(error)
      end

      it 'returns error with messages when an error is raised' do
        post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1 }
        json_response = JSON.parse(response.body)
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(json_response.dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
        end
      end
    end
  end

  describe 'GET #download' do
    let(:hubs) do
      [
        create(:hub,
               tenant: tenant,
               name: 'Gothenburg Port',
               hub_type: 'ocean',
               nexus: create(:nexus, name: 'Gothenburg')),
        create(:hub,
               tenant: tenant,
               name: 'Shanghai Port',
               hub_type: 'ocean',
               nexus: create(:nexus, name: 'Shanghai'))
      ]
    end
    let(:tenant_vehicle) do
      create(:tenant_vehicle, tenant: tenant)
    end

    before do
      create(
        :local_charge,
        mode_of_transport: 'ocean',
        load_type: 'lcl',
        hub: hubs.first,
        tenant: tenant,
        tenant_vehicle: tenant_vehicle,
        counterpart_hub_id: hubs.second,
        direction: 'export',
        fees: { 'DOC' => { 'key' => 'DOC', 'max' => nil, 'min' => nil, 'name' => 'Documentation', 'value' => 20, 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' } },
        dangerous: nil,
        effective_date: Date.parse('Thu, 24 Jan 2019'),
        expiration_date: Date.parse('Fri, 24 Jan 2020'),
        user_id: nil
      )
      create(:tenants_scope, target: Tenants::Tenant.find_by(legacy_id: tenant.id), content: { 'base_pricing' => true })
    end

    it 'returns error with messages when an error is raised' do
      get :download, params: { tenant_id: tenant.id, options: { mot: nil, group_id: nil } }
      json_response = JSON.parse(response.body)
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'url')).to include('demo__local_charges_.xlsx')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:local_charge) do
      create(:legacy_local_charge,
             tenant: tenant,
             effective_date: Date.parse('Thu, 24 Jan 2019'),
             expiration_date: Date.parse('Fri, 24 Jan 2020'))
    end

    it 'returns an http status of success' do
      delete :destroy, params: { tenant_id: tenant, id: local_charge.id }
      expect(response).to have_http_status(:success)
    end

    it 'removes the local_charge' do
      delete :destroy, params: { tenant_id: tenant, id: local_charge.id }
      expect(::Legacy::LocalCharge.find_by(id: local_charge.id)).to be(nil)
    end
  end
end
