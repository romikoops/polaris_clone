# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ItinerariesController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:organizations_membership) { FactoryBot.create(:organizations_membership, role: :admin, organization: organization, member: user) }
  let!(:itineraries) do
    [
      FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization),
      FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization),
      FactoryBot.create(:felixstowe_shanghai_itinerary, organization: organization),
      FactoryBot.create(:shanghai_felixstowe_itinerary, organization: organization),
      FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization),
      FactoryBot.create(:shanghai_hamburg_itinerary, organization: organization)
    ]
  end

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    append_token_header
  end

  describe 'GET #index' do
    let(:params) do
      {
        organization_id: organization.id,
        per_page: 6,
        page: 1
      }
    end

    it 'returns http success and index data' do
      get :index, params: params

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data', 'itinerariesData').length).to eq 6
      expect(json.dig('data', 'itinerariesData').pluck('id')).to match_array(itineraries.pluck(:id))
    end

    it 'returns http success and index data filtered by name' do
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
    it 'returns http success' do
      get :show, params: { organization_id: organization.id, id: itineraries.first.id }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data').keys).to match_array(%w(itinerary validationResult notes))
      expect(json.dig('data', 'itinerary', 'id')).to eq(itineraries.first.id)
    end
  end

  describe 'GET #stops' do
    it 'returns http success' do
      get :stops, params: { organization_id: organization.id, id: itineraries.first.id }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data').length).to eq(2)
      expect(json.dig('data').pluck('id')).to eq(itineraries.first.stops.ids)
    end
  end
end
