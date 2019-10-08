# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::ItinerariesController, type: :controller do 
    routes { Engine.routes }

    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant) }
    let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }

    subject do
      request.headers['Authorization'] = token_header
      request_object
    end

    describe 'GET #itineraries' do
      let(:request_object) do
        get :index, as: :json
      end

      before do
        FactoryBot.create_list(:legacy_itinerary, 5, :default, tenant: legacy_tenant, name: 'Ningbo - Gothenburg')
        allow_any_instance_of(Tenants::User).to receive(:tenant).and_return(tenant)
      end

      it 'should return a list of itineraries belonging to the tenant' do
        data = JSON.parse(subject.body)
        expect(response).to be_successful
        expect(data).not_to be_empty
        expect(data.length).to eq(5)
      end
    end
  end
end
