# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::ClientsController, type: :controller do
    routes { Engine.routes }

    subject do
      request.headers['Authorization'] = token_header
      request_object
    end

    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant, slug: '1234') }
    let(:tenant_group) { Tenants::Group.create(tenant: tenant) }
    let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe 'GET #index' do
      let(:request_object) do
        get :index, as: :json
      end

      before do
        users = FactoryBot.create_list(:legacy_user, 5, guest: false, tenant: user.tenant.legacy)
        users.each { |user| FactoryBot.create(:profiles_profile, user_id: Tenants::User.find_by(legacy_id: user.id).id) }
        allow_any_instance_of(Tenants::User).to receive(:tenant).and_return(tenant)
      end

      it 'renders the list of users successfully' do
        json = JSON.parse(subject.body)
        expect(response).to be_successful
        expect(json['data']).not_to be_empty
      end
    end

    describe 'Get #show' do
      let(:user) { FactoryBot.create(:legacy_user) }
      let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
      let(:request_object) { get :show, params: { id: tenants_user.id }, as: :json }

      before do
        FactoryBot.create(:profiles_profile,
                          first_name: 'Max',
                          last_name: 'Muster',
                          user_id: tenants_user.id)
      end

      it 'returns the requested client correctly' do
        json = JSON.parse(subject.body)
        expect(response).to be_successful
        expect(json['data']).not_to be_empty
        %w[companyName email phone firstName lastName].each do |key|
          expect(json['data']['attributes']).to have_key(key)
        end
      end
    end

    describe 'POST #create' do
      let(:user_info) { FactoryBot.attributes_for(:legacy_user).merge(group_id: tenant_group.id) }
      let(:profile_info) { FactoryBot.attributes_for(:profiles_profile) }
      let(:country) { FactoryBot.create(:legacy_country) }
      let(:role) { FactoryBot.create(:legacy_role) }
      let(:perform_request) { subject }
      let(:address_info) do
        { street: 'Brooktorkai', house_number: '7', city: 'Hamburg', postal_code: '22047', country: country.name }
      end
      let(:request_object) do
        post :create, params: { client: { **user_info, **profile_info, **address_info, role: role.name } }, as: :json
      end

      context 'when request is successful' do
        it 'returns http status of success' do
          perform_request
          expect(response).to have_http_status(:success)
        end

        it 'creates the user successfully' do
          perform_request
          expect(Legacy::User.find_by(email: user_info[:email])).not_to be_nil
        end
      end

      context 'when creating clients without role' do
        let(:request_object) do
          post :create, params: { client: { **user_info, **profile_info, **address_info } }
        end

        before do
          FactoryBot.create(:legacy_role, name: 'shipper')
        end

        it 'assigns the default role (shipper) to the new user' do
          perform_request
          user = Legacy::User.find_by(email: user_info[:email])
          expect(user.role.name).to eq('shipper')
        end
      end

      context 'when creating clients without group_id params' do
        let(:user_info) { FactoryBot.attributes_for(:legacy_user) }

        before do
          FactoryBot.create(:tenants_group, tenant: tenant, name: 'default')
        end

        it 'assigns the default group of the tenant to the new user membership' do
          perform_request
          user = Legacy::User.find_by(email: user_info.dig(:email))
          expect(user.all_groups.pluck(:name)).to include('default')
        end
      end

      context 'when request is unsuccessful (bad or missing data)' do
        let(:request_object) do
          post :create, params: { client: { **user_info, **profile_info, **address_info, role: role.name, email: nil } }, as: :json
        end

        it 'returns with a 400 response' do
          perform_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns list of errors' do
          json = JSON.parse(perform_request.body)
          expect(json['error']).to include("Validation failed: Email can't be blank, Email is invalid")
        end
      end
    end
  end
end
