# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SchedulesController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:role) { FactoryBot.create(:legacy_role, name: 'Admin') }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, role: role) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }

  describe 'GET #show' do
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: 'MSC') }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier: carrier) }
    let(:closing_date) { Date.today }
    let(:start_date) { Date.today + 4.days }
    let(:end_date) { Date.today + 30.days }
    let!(:trips) do
      (1..10).map do |delta|
        FactoryBot.create(:legacy_trip,
                          itinerary: itinerary,
                          closing_date: closing_date + delta.days,
                          start_date: start_date + delta.days,
                          end_date: end_date + delta.days,
                          tenant_vehicle: tenant_vehicle)
      end
    end
    let(:edit_params) do
      {
        id: itinerary.id,
        tenant_id: user.tenant_id
      }
    end
    it 'returns http success' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      get :show, params: edit_params
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data', 'schedules').length).to eq 10
      expect(json.dig('data', 'schedules', 0, 'carrier')).to eq 'MSC'
      expect(json.dig('data', 'schedules', 0, 'service_level')).to eq 'standard'
    end
  end

  context 'when uplaoding schedules' do
    let(:errors_arr) do
      [{ row_no: 1, reason: 'A' },
       { row_no: 2, reason: 'B' },
       { row_no: 3, reason: 'C' },
       { row_no: 4, reason: 'D' }]
    end
    let(:error) { { has_errors: true, errors: errors_arr } }
    before do
      expect_any_instance_of(described_class).to receive(:require_authentication!).and_return(true)
      expect_any_instance_of(described_class).to receive(:require_non_guest_authentication!).and_return(true)
      expect_any_instance_of(described_class).to receive(:require_login_and_role_is_admin).and_return(true)
      expect_any_instance_of(described_class).to receive(:current_tenant).at_least(:once).and_return(double('Tenant', scope: {}, subdomain: 'test', id: 1))
      expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(double('User', guest: false, email: 'test@test.com', id: 1, agency_id: nil, agency: nil, tenant: nil, groups: nil, company: nil, scope: nil, sandbox: nil))
      expect(Document).to receive(:create!)
      expect_any_instance_of(ExcelDataServices::Loaders::Uploader).to receive(:perform).and_return(error)
    end

    describe 'POST #upload' do
      context 'error testing' do
        it 'returns error with messages when an error is raised' do
          post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1, mot: 'ocean', load_type: 'cargo_item' }
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:success)
          expect(json_response.dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
        end
      end
    end

    describe 'POST #generate_schedules_from_sheet' do
      context 'error testing' do
        it 'returns error with messages when an error is raised' do
          post :generate_schedules_from_sheet, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1, mot: 'ocean', load_type: 'cargo_item' }
          json_response = JSON.parse(response.body)
          expect(response).to have_http_status(:success)
          expect(json_response.dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
        end
      end
    end
  end
end
