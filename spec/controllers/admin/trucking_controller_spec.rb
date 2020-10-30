# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TruckingController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:hub) { FactoryBot.create(:legacy_hub, organization: organization) }
  let(:json_response) { JSON.parse(response.body) }

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    append_token_header
  end

  describe 'POST #overwrite_zonal_trucking_by_hub' do
    before do
      post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), organization_id: organization.id, group: 'all', id: hub.id }
    end

    it 'returns error with messages when an error is raised' do
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response['data']).to be_truthy
      end
    end
  end

  describe 'GET #show' do
    let(:courier_name) { 'Test Courier' }
    let(:group) { FactoryBot.create(:groups_group, organization: organization) }
    let(:courier) { FactoryBot.create(:legacy_tenant_vehicle, name: courier_name, organization: organization) }

    before do
      FactoryBot.create(:trucking_trucking, hub: hub, tenant_vehicle: courier, organization: organization, group: group)
    end

    it 'returns the truckings for the requested hub' do
      get :show, params: { id: hub.id, organization_id: organization.id, group: group.id }
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'groups')).not_to be_empty
        expect(json_response.dig('data', 'truckingPricings').first.dig('truckingPricing', 'hub_id')).to eq(hub.id)
        expect(json_response.dig('data', 'providers')).to include(courier_name)
      end
    end
  end
end
