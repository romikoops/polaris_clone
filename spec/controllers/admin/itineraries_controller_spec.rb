# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ItinerariesController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:role) { FactoryBot.create(:legacy_role, name: 'Admin') }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, role: role) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let!(:itineraries) do
    [
      FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant),
      FactoryBot.create(:shanghai_gothenburg_itinerary, tenant: tenant),
      FactoryBot.create(:felixstowe_shanghai_itinerary, tenant: tenant),
      FactoryBot.create(:shanghai_felixstowe_itinerary, tenant: tenant),
      FactoryBot.create(:hamburg_shanghai_itinerary, tenant: tenant),
      FactoryBot.create(:shanghai_hamburg_itinerary, tenant: tenant)
    ]
  end

  describe 'GET #index' do
    let(:params) do
      {
        tenant_id: user.tenant_id,
        per_page: 6,
        page: 1
      }
    end
    it 'returns http success and index data' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      get :index, params: params

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data', 'itinerariesData').length).to eq 6
      expect(json.dig('data', 'itinerariesData').pluck('id')).to match_array(itineraries.pluck(:id))
    end

    it 'returns http success and index data filtered by name' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      search_params = {
        name: 'Gothenburg',
        name_desc: true
      }.merge(params)

      get :index, params: search_params

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data', 'itinerariesData').length).to eq 2
      expect(json.dig('data', 'itinerariesData').pluck('id')).to match_array([itineraries[0].id, itineraries[1].id])
    end

    it 'returns http success and index data filtered by mot' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      search_params = {
        mot: 'ocean',
        mot_desc: true
      }.merge(params)

      get :index, params: search_params

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data', 'itinerariesData').length).to eq 6
      expect(json.dig('data', 'itinerariesData').pluck('id')).to match_array(itineraries.pluck(:id))
    end
  end

  describe 'GET #show' do
    let(:params) do
      {
        tenant_id: user.tenant_id,
        id: itineraries.first.id
      }
    end
    it 'returns http success' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      get :show, params: params

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data').keys).to match_array(%w(itinerary validationResult notes))
      expect(json.dig('data', 'itinerary', 'id')).to eq(itineraries.first.id)
    end
  end
end
