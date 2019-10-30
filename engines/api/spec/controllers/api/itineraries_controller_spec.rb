# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::ItinerariesController, type: :controller do
    routes { Engine.routes }

    let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe 'GET #itineraries' do

      let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenant) { FactoryBot.create(:tenants_tenant, legacy: legacy_tenant) }

      before do
        FactoryBot.create_list(:legacy_itinerary, 5, :default, tenant: legacy_tenant, name: 'Ningbo - Gothenburg')
        allow_any_instance_of(Tenants::User).to receive(:tenant).and_return(tenant)
      end

      subject do
        request.headers['Authorization'] = token_header
        request_object
      end

      let(:request_object) do
        get :index, as: :json
      end

      it 'should return a list of itineraries belonging to the tenant' do
        expect(response).to be_successful
        expect(subject.body).not_to be_empty

        data = JSON.parse(subject.body)
        expect(data.length).to eq(5)
      end
    end

    describe 'GET #ports' do
      subject do
        legacy_tenant = FactoryBot.create(:legacy_tenant)
        Tenants::Tenant.find_by(legacy: legacy_tenant)
      end

      it 'should return a list of ocean itineraries belonging to the tenant' do
        FactoryBot.create_list(:legacy_itinerary, 5, :default, tenant: subject.legacy, name: 'Ningbo - Gothenburg')

        get :ports, params: { tenant_uuid: subject.id }, as: :json

        expect(response).to be_successful
        expect(response.body).not_to be_empty

        data = JSON.parse(response.body)
        expect(data['data'].length).to eq(5)
      end

      it 'should not return itineraries from other tenants' do
        FactoryBot.create_list(:legacy_itinerary, 2, :default, tenant: subject.legacy, name: 'Ningbo - Gothenburg')

        get :ports, params: { tenant_uuid: subject.id }, as: :json

        expect(response).to be_successful
        expect(response.body).not_to be_empty

        data = JSON.parse(response.body)
        expect(data['data'].length).to eq(2)
      end

      it 'should return empty if there are no no itineraries for the tenant' do
        get :ports, params: { tenant_uuid: subject.id }, as: :json

        expect(response).to be_successful
        expect(response.body).not_to be_empty

        data = JSON.parse(response.body)
        expect(data['data'].length).to eq(0)
      end
    end
  end
end
