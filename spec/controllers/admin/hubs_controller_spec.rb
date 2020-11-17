# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::HubsController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:gothenburg) { FactoryBot.create(:gothenburg_hub, organization: organization) }
  let!(:user) { FactoryBot.create(:authentication_user, :organizations_user, organization_id: organization.id) }
  let!(:felixstowe) { FactoryBot.create(:felixstowe_hub, organization: organization) }
  let!(:shanghai) { FactoryBot.create(:shanghai_hub, organization: organization) }
  before(:each) do
    FactoryBot.create(:groups_group, :default, organization: organization)
    expect_any_instance_of(described_class).to receive(:doorkeeper_authorize!).and_return(true)
    expect_any_instance_of(described_class).to receive(:current_organization).at_least(:once).and_return(organization)
    expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(user)
  end

  describe 'GET #index' do
    it 'returns a response with paginated results' do
      get :index, params: { organization_id: gothenburg.organization.id, hub_type: gothenburg.hub_type, hub_status: gothenburg.hub_status }
      expect(response).to have_http_status(:success)
    end

    it 'returns a response with paginated results filtered by country' do
      params = {
        organization_id: gothenburg.organization.id,
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
        organization_id: gothenburg.organization.id,
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
        organization_id: gothenburg.organization.id,
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
        organization_id: gothenburg.organization.id,
        type_desc: true,
        type: 'ocean'
      }
      get :index, params: params
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.dig('data', 'hubsData').pluck('id')).to match_array([felixstowe.id, gothenburg.id, shanghai.id])
    end
  end

  describe 'Get #options_search' do
    let(:hub_name) { 'Test Hub' }
    before do
      FactoryBot.create(:legacy_hub, organization: organization, name: hub_name)
    end

    it 'returns the hubs matching the query sent' do
      get :options_search, params: { organization_id: organization.id, query: 'Test' }
      json_response = JSON.parse(response.body)
      hub_names = json_response.dig('data').pluck('label')
      expect(hub_names).to include("#{hub_name} Port")
    end
  end

  describe 'POST #upload' do
    let(:perform_request) { post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), organization_id: organization.id } }

    context 'raises an error' do
      let(:errors_arr) do
        [{ row_no: 1, reason: 'A' },
         { row_no: 2, reason: 'B' },
         { row_no: 3, reason: 'C' },
         { row_no: 4, reason: 'D' }]
      end
      let(:error) { { has_errors: true, errors: errors_arr } }

      let(:complete_email_job) { performed_jobs.find { |j| j[:args][0] == "UploadMailer" } }
      let(:resulted_errors) { complete_email_job[:args][3]['result']['errors'].map { |err| err.except('_aj_symbol_keys') } }

      before do
        expect_any_instance_of(ExcelDataServices::Loaders::Uploader).to receive(:perform).and_return(error)

        allow(controller).to receive(:current_organization).and_return(organization)
      end

      it_behaves_like 'uploading request async'

      it 'sends an email with the upload errors' do
        perform_enqueued_jobs do
          perform_request
        end

        expect(resulted_errors).not_to be_empty
      end
    end
  end

  describe 'GET #download' do
    context 'unsuccesfully downloads' do
      let!(:hubs) { FactoryBot.create(:gothenburg_hub, free_out: false, organization: organization, mandatory_charge: FactoryBot.create(:mandatory_charge), nexus: FactoryBot.create(:gothenburg_nexus)) }

      it 'returns error with messages when an error is raised' do
        get :download, params: { organization_id: organization.id }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'url').include?(organization.slug)).to be_truthy
      end
    end
  end

  describe 'POST #set_status' do
    context 'sets the hub status to inactive' do
      it 'rsets the hub status to ' do
        post :set_status, params: { hub_id: gothenburg.id, organization_id: organization.id }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'data', 'hub_status')).to eq('inactive')
      end
    end
  end

  describe 'GET #show' do
    context 'returns the hub and related data' do
      it 'returns the correct hub and related data' do
        get :show, params: { id: gothenburg.id, organization_id: organization.id }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data').keys).to match_array(%w[hub routes relatedHubs schedules address mandatoryCharge])
      end
    end
  end

  describe 'POST #update_mandatory_charges' do
    let!(:desired_mandatory_charge) do
      FactoryBot.create(:mandatory_charge,
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
          organization_id: organization.id
        }
        post :update_mandatory_charges, params: params
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'hub', 'mandatory_charge_id')).to eq(desired_mandatory_charge.id)
      end
    end
  end
end
