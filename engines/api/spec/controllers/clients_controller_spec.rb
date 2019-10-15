# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::ClientsController, type: :controller do
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

    describe 'GET #index' do
      let(:request_object) do
        get :index, as: :json
      end

      before do
        FactoryBot.create_list(:legacy_user, 5, guest: false, tenant: user.tenant.legacy)
        allow_any_instance_of(Tenants::User).to receive(:tenant).and_return(tenant)
      end

      it 'renders the list of users successfully' do
        json = JSON.parse(subject.body)
        expect(response).to be_successful
        expect(json['data']).not_to be_empty
      end
    end

    describe 'Get #show' do
      let(:user) { FactoryBot.create(:legacy_user, first_name: 'Max', last_name: 'Muster')}
      let(:request_object) { get :show, params: { id: user.id }, as: :json }

      it 'returns the requested client correctly' do
        json = JSON.parse(subject.body)
        expect(response).to be_successful
        expect(json['data']).not_to be_empty
        %w(company-name email phone first-name last-name).each do |key|
          expect(json['data']['attributes']).to have_key(key)
        end
      end
    end
  end
end
