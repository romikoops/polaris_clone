# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SchedulesController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:role) { FactoryBot.create(:legacy_role, name: 'Admin') }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, role: role) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_tenant).and_return(tenant)
    allow(controller).to receive(:require_authentication!).and_return(true)
    allow(controller).to receive(:require_non_guest_authentication!).and_return(true)
    allow(controller).to receive(:require_login_and_role_is_admin).and_return(true)
  end

  describe 'GET #index' do
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: 'MSC') }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier) }
    let(:closing_date) { Time.zone.today }
    let(:start_date) { Time.zone.today + 4.days }
    let(:end_date) { Time.zone.today + 30.days }

    before do
      (1..10).map do |delta|
        FactoryBot.create(:legacy_trip,
                          itinerary: itinerary,
                          closing_date: closing_date + delta.days,
                          start_date: start_date + delta.days,
                          end_date: end_date + delta.days,
                          tenant_vehicle: tenant_vehicle)
      end
      get :index, params: { tenant_id: user.tenant_id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: 'MSC') }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier) }
    let(:closing_date) { Time.zone.today }
    let(:start_date) { Time.zone.today + 4.days }
    let(:end_date) { Time.zone.today + 30.days }
    let(:edit_params) do
      {
        id: itinerary.id,
        tenant_id: user.tenant_id
      }
    end

    before do
      (1..10).map do |delta|
        FactoryBot.create(:legacy_trip,
                          itinerary: itinerary,
                          closing_date: closing_date + delta.days,
                          start_date: start_date + delta.days,
                          end_date: end_date + delta.days,
                          tenant_vehicle: tenant_vehicle)
      end
      get :show, params: edit_params
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns the edited data' do
      aggregate_failures do
        expect(JSON.parse(response.body).dig('data', 'schedules').length).to eq 10
        expect(JSON.parse(response.body).dig('data', 'schedules', 0, 'carrier')).to eq 'MSC'
        expect(JSON.parse(response.body).dig('data', 'schedules', 0, 'service_level')).to eq 'standard'
      end
    end
  end

  context 'when uploading schedules' do
    let(:errors_arr) do
      [{ row_no: 1, reason: 'A' },
       { row_no: 2, reason: 'B' },
       { row_no: 3, reason: 'C' },
       { row_no: 4, reason: 'D' }]
    end
    let(:error) { { has_errors: true, errors: errors_arr } }

    before do
      allow(Legacy::File).to receive(:create!)
      excel_data_service = instance_double('ExcelDataServices::Loaders::Uploader', perform: error)
      allow(ExcelDataServices::Loaders::Uploader).to receive(:new).and_return(excel_data_service)
    end

    describe 'POST #upload' do
      it 'returns error with messages when an error is raised' do
        post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1, mot: 'ocean', load_type: 'cargo_item' }
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body).dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
        end
      end
    end

    describe 'POST #generate_schedules_from_sheet' do
      it 'returns error with messages when an error is raised' do
        post :generate_schedules_from_sheet, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1, mot: 'ocean', load_type: 'cargo_item' }
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body).dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
        end
      end
    end
  end
end
