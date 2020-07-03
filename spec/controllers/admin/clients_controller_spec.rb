# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ClientsController do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:authentication_user, :users_user, :with_profile) }

  before do
    append_token_header
  end

  describe 'GET #index' do
    let(:organization_2) { FactoryBot.create(:organizations_organization, slug: 'demo2') }
    let(:company) { FactoryBot.create(:companies_company, name: 'ItsMyCargo', organization_id: organization_2.id) }
    let(:users) do
      [{
        first_name: 'A Test',
        last_name: 'A User',
        email: 'atestuser@itsmycargo.com'
      },
       {
         first_name: 'B Test',
         last_name: 'B User',
         email: 'btestuser@itsmycargo.com'
       },
       {
         first_name: 'C Test',
         last_name: 'C User',
         email: 'ctestuser@itsmycargo.com'
       }]
    end

    before do
      ::Organizations.current_id = organization_2.id
      users.each do |user_details|
        user = FactoryBot.create(:users_user,
                                 email: user_details[:email],
                                 organization_id: organization_2.id)
        FactoryBot.create(:companies_membership, company: company, member: user)
        FactoryBot.create(:profiles_profile,
                          first_name: user_details[:first_name],
                          last_name: user_details[:last_name],
                          user_id: user.id)
      end
    end

    it 'returns an http status of success' do
      get :index, params: { organization_id: organization_2.id }
      expect(response).to have_http_status(:success)
    end

    context 'with query search' do
      it 'returns the correct matching results with search' do
        get :index, params: { organization_id: organization_2.id, query: 'btestuser' }
        resp = JSON.parse(response.body)
        expect(resp['data']['clientData'].first['email']).to eq('btestuser@itsmycargo.com')
      end
    end

    context 'when searching via company names' do
      it 'returns users matching the given company_name ' do
        get :index, params: { organization_id: organization_2.id, company_name: 'ItsMyCargo' }
        resp = JSON.parse(response.body)

        expect(resp['data']['clientData'].pluck('email')).to include(users.sample[:email])
      end
    end

    shared_examples_for 'A searchable & orderable collection' do |search_keys|
      search_keys.each do |search_key|
        context "#{search_key} search & ordering" do
          it 'yields the correct matching results for search' do
            sample_user = users.sample
            get :index, params: { search_key => sample_user[search_key.to_sym], organization_id: organization_2.id }
            resp = JSON.parse(response.body)
            expect(resp['data']['clientData'].first[search_key.camelize(:lower)]).to eq(sample_user[search_key.to_sym])
          end

          it 'sorts the result according to the param provided' do
            expected_response = users.pluck(search_key.to_sym).sort.reverse
            get :index, params: { "#{search_key}_desc" => 'true', organization_id: organization_2.id }
            resp = JSON.parse(response.body)
            expect(resp['data']['clientData'].pluck(search_key.camelize(:lower))).to eq(expected_response)
          end
        end
      end
    end
    it_behaves_like 'A searchable & orderable collection', %w[first_name last_name email]
  end

  describe 'GET #show' do
    let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }

    it 'returns an http status of success' do
      post :show, params: { organization_id: organization, id: user }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'post #create' do
    let(:user_attributes) { attributes_for(:user, email: 'email123@demo.com').deep_transform_keys { |k| k.to_s.camelize(:lower) } }
    let(:profile_attributes) { attributes_for(:profiles_profile).deep_transform_keys { |k| k.to_s.camelize(:lower) } }
    let(:attributes) { user_attributes.merge(profile_attributes) }

    before do
      FactoryBot.create(:organizations_theme, organization: organization)
    end

    it 'returns an http status of success' do
      post :create, params: { organization_id: organization, new_client: attributes.to_json }
      expect(response).to have_http_status(:success)
    end

    it 'creates the user' do
      post :create, params: { organization_id: organization, new_client: attributes.to_json }
      expect(Users::User.where(organization_id: organization.id).last.email).to eq(attributes['email'])
    end
  end

  describe 'POST #agents' do
    let(:uploader) { double(perform: nil) }
    let(:file) { fixture_file_upload('spec/fixtures/files/excel/dummy.xlsx') }

    before do
      allow(ExcelDataServices::Loaders::Uploader).to receive(:new).with(anything).and_return(uploader)
    end

    context 'with base pricing' do
      before do
        scope = ::OrganizationManager::ScopeService.new(target: ::Organizations::User.find_by(id: user), organization: ::Organizations::Organization.find_by(id: organization)).fetch
        scope[:base_pricing] = true

        allow(controller).to receive(:current_scope).and_return(scope)
      end

      it 'send the uploaded file to correct uploader' do
        expect(ExcelDataServices::Loaders::Uploader).to receive(:new).with(anything).and_return(uploader)

        post :agents, params: { organization_id: organization, file: file }
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { FactoryBot.create(:organizations_user, organization: organization) }

    it 'returns an http status of success' do
      delete :destroy, params: { organization_id: organization, id: user.id }
      expect(response).to have_http_status(:success)
    end

    it 'the removal of the user' do
      delete :destroy, params: { organization_id: organization, id: user.id }
      expect(User.find_by(id: user.id)).to be(nil)
    end
  end
end
