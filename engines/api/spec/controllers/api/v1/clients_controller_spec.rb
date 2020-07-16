# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::ClientsController, type: :controller do
    routes { Engine.routes }

    subject do
      request.headers['Authorization'] = token_header
      request_object
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:organization_group) { Groups::Group.create(organization: organization) }
    let(:user) { FactoryBot.create(:users_user, :with_profile, email: 'test@example.com') }

    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:perform_request) { subject }

    before do
      ::Organizations.current_id = organization.id
    end

    describe 'GET #index' do
      let(:request_object) do
        get :index, params: { organization_id: organization.id }, as: :json
      end

      before do
        FactoryBot.create_list(:organizations_user, 5, :with_profile, organization: organization)
      end

      it 'renders the list of users successfully' do
        perform_request
        aggregate_failures do
          expect(response).to be_successful
          expect(response_data).not_to be_empty
        end
      end
    end

    describe 'Get #show' do
      let(:org_user) { FactoryBot.create(:organizations_user, organization: organization) }
      let(:request_object) { get :show, params: { organization_id: organization.id, id: org_user.id }, as: :json }

      before do
        FactoryBot.create(:profiles_profile,
                          first_name: 'Max',
                          last_name: 'Muster',
                          user_id: org_user.id)
      end

      it 'returns the requested client correctly' do
        perform_request
        expect(response).to be_successful

        expect(response_data).not_to be_empty
        %w[companyName email phone firstName lastName].each do |key|
          expect(response_data['attributes']).to have_key(key)
        end
      end
    end

    describe 'PATCH #update' do
      let(:user) {
        FactoryBot.create(:authentication_user,
       :organizations_user,
        :with_profile,
        :active,
         organization_id: organization.id)
      }
      let(:profile) { Profiles::Profile.find_by(user_id: user.id) }

      before do
        FactoryBot.create(:organizations_theme, organization: organization, name: "Demo")
        FactoryBot.create(:organizations_domain, default: true, organization: organization, domain: "demo")
      end

      context 'when request is successful' do
        let(:request_object) {
          patch :update, params: { organization_id: organization.id,
                                   id: user.id,
                                   client: {
                                     email: 'bassam@itsmycargo.com',
                                     first_name: 'Bassam', last_name: 'Aziz',
                                     company_name: 'ItsMyCargo',
                                     phone: '123123'
                                   }}, as: :json
        }

        it 'returns an http status of success' do
          perform_request
          expect(response).to be_successful
        end

        it 'updates the user profile successfully' do
          perform_request
          expect(profile.first_name).to eq('Bassam')
        end

        it 'updates the user email successfully' do
          perform_request
          user.reload
          expect(user.activation_state).to eq('pending')
          expect(user.email).to eq('bassam@itsmycargo.com')
        end
      end

      context 'when update email request is invalid' do
        let(:request_object) {
          patch :update, params: { organization_id: organization,
                                   id: user.id, client: {
                                     email: nil,
                                     first_name: 'Bassam', last_name: 'Aziz',
                                     company_name: 'ItsMyCargo',
                                     phone: '123123'
                                   } }, as: :json
        }

        it 'returns with a 422 response' do
          perform_request
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns list of errors' do
          json = JSON.parse(perform_request.body)
          expect(json['error']).to include("Validation failed: Email can't be blank, Email is invalid")
        end
      end

      context 'when update profile request is invalid' do
        let(:request_object) {
          patch :update, params: { organization_id: organization,
                                   id: user.id, client: {
                                     email: 'bassam@itsmycargo.com',
                                     first_name: nil, last_name: 'Aziz',
                                     company_name: 'ItsMyCargo',
                                     phone: '1231234'
                                   }}, as: :json
        }

        it 'returns with a 422 response' do
          perform_request
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update profile' do
          perform_request
          expect(profile.first_name).not_to be_nil
        end

        it 'returns list of errors' do
          json = JSON.parse(perform_request.body)
          expect(json['error']).to include("Validation failed: First name can't be blank")
        end
      end
    end

    describe 'POST #create' do
      let(:user_info) { FactoryBot.attributes_for(:organizations_user, organization_id: organization.id).merge(group_id: organization_group.id) }
      let(:profile_info) { FactoryBot.attributes_for(:profiles_profile) }
      let(:country) { FactoryBot.create(:legacy_country) }
      let(:address_info) do
        { street: 'Brooktorkai', house_number: '7', city: 'Hamburg', postal_code: '22047', country: country.name }
      end
      let(:request_object) do
        post :create, params: { organization_id: organization.id, client: { **user_info, **profile_info, **address_info } }, as: :json
      end

      context 'when request is successful' do
        it 'returns http status of success' do
          perform_request
          expect(response).to have_http_status(:success)
        end

        it 'creates the user successfully' do
          perform_request
          expect(Organizations::User.find_by(email: user_info[:email])).not_to be_nil
        end
      end

      context 'when creating clients without role' do
        let(:request_object) do
          post :create, params: { organization_id: organization.id, client: { **user_info, **profile_info, **address_info } }
        end

        it 'assigns the default role (shipper) to the new user' do
          perform_request
          user = Organizations::User.find_by(email: user_info[:email])

          expect(user.organization_id).to eq(user_info[:organization_id])
        end
      end

      context 'when creating clients without group_id params' do
        let(:user_info) { FactoryBot.attributes_for(:organizations_user, organization_id: organization.id) }

        before do
          FactoryBot.create(:groups_group, organization: organization, name: 'default')
        end

        it 'assigns the default group of the organization to the new user membership' do
          perform_request
          user = Organizations::User.find_by(email: user_info[:email])
          expect(user.groups.pluck(:name)).to include('default')
        end
      end

      context 'when request is unsuccessful (bad or missing data)' do
        let(:request_object) do
          post :create, params: { organization_id: organization.id, client: { **user_info, **profile_info, **address_info, email: nil } }, as: :json
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

    describe 'DELETE #destroy' do
      let(:user) {
        FactoryBot.create(:authentication_user,
        :organizations_user,
        :with_profile,
        :active,
        organization_id: organization.id)
      }
      let(:profile) { Profiles::Profile.with_deleted.find_by(user_id: user.id) }
      let(:organization_user) { Organizations::User.with_deleted.find_by(id: user.id) }
      let(:request_object) {
        delete :destroy,
        params: { organization_id: organization.id,
                  id: user.id },
        as: :json
      }

      context 'when request is successful' do
        it 'deletes the client successfully' do
          perform_request
          expect(response).to be_successful
        end

        it 'deletes the profile successfully' do
          perform_request
          expect(profile.deleted?).to be_truthy
        end

        it 'deletes the authentication user successfully' do
          perform_request
          user.reload
          expect(user.deleted?).to be_truthy
        end

        it 'deletes the organization user successfully' do
          perform_request
          user.reload
          expect(organization_user.deleted?).to be_truthy
        end
      end

      context 'when request cannot find a user' do
        before do
          user.destroy!
        end

        it 'returns with a 404 response' do
          perform_request
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
