# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SchedulesController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:organizations_membership) { FactoryBot.create(:organizations_membership, role: :admin, organization: organization, member: user) }

  before do
    append_token_header
  end

  describe 'GET #index' do
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:carrier) { FactoryBot.create(:carrier, name: 'MSC') }
    let(:tenant_vehicle) { FactoryBot.create(:tenant_vehicle, carrier: carrier) }
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
      get :index, params: { organization_id: organization.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:carrier) { FactoryBot.create(:carrier, name: 'MSC') }
    let(:tenant_vehicle) { FactoryBot.create(:tenant_vehicle, carrier: carrier) }
    let(:tenant_vehicle_no_carrier) { FactoryBot.create(:tenant_vehicle, carrier: nil) }
    let(:closing_date) { Time.zone.today }
    let(:start_date) { Time.zone.today + 4.days }
    let(:end_date) { Time.zone.today + 30.days }
    let(:show_params) do
      {
        id: itinerary.id,
        organization_id: organization.id
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
      FactoryBot.create(:legacy_trip,
                        itinerary: itinerary,
                        closing_date: closing_date + 2.days,
                        start_date: start_date + 2.days,
                        end_date: end_date + 2.days,
                        tenant_vehicle: tenant_vehicle_no_carrier)
      get :show, params: show_params
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns the edited data' do
      aggregate_failures do
        expect(JSON.parse(response.body).dig('data', 'schedules').length).to eq 11
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
        post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), organization_id: organization.id, mot: 'ocean', load_type: 'cargo_item' }
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body).dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
        end
      end
    end

    describe 'POST #generate_schedules_from_sheet' do
      it 'returns error with messages when an error is raised' do
        post :generate_schedules_from_sheet, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), organization_id: organization.id, mot: 'ocean', load_type: 'cargo_item' }
        aggregate_failures do
          expect(response).to have_http_status(:success)
          expect(JSON.parse(response.body).dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
        end
      end
    end
  end
end
