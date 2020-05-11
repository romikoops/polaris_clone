# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ClientsController do
  let(:tenant) { FactoryBot.create(:tenant) }
  let(:user) { FactoryBot.create(:user, tenant: tenant, with_profile: true) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    let(:tenant_2) { FactoryBot.create(:tenant, subdomain: 'demo2') }
    let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant_2.id) }
    let(:tenants_company) { FactoryBot.create(:tenants_company, name: 'ItsMyCargo', tenant_id: tenants_tenant.id) }
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
      users.each do |user_details|
        user = FactoryBot.create(:legacy_user,
                                 email: user_details[:email],
                                 tenant: tenant_2,
                                 with_profile: false)
        tenants_user = Tenants::User.find_by(legacy_id: user.id)
        tenants_user.update(company_id: tenants_company.id)
        FactoryBot.create(:profiles_profile,
                          first_name: user_details[:first_name],
                          last_name: user_details[:last_name],
                          user_id: tenants_user.id)
      end
    end

    it 'returns an http status of success' do
      get :index, params: { tenant_id: tenant_2 }
      expect(response).to have_http_status(:success)
    end

    context 'with query search' do
      it 'returns the correct matching results with search' do
        get :index, params: { tenant_id: tenant_2.id, query: 'btestuser' }
        resp = JSON.parse(response.body)
        expect(resp['data']['clientData'].first['email']).to eq('btestuser@itsmycargo.com')
      end
    end

    context 'when searching via company names' do
      it 'returns users matching the given company_name ' do
        get :index, params: { tenant_id: tenant_2.id, company_name: 'ItsMyCargo' }
        resp = JSON.parse(response.body)
        expect(resp['data']['clientData'].pluck('email')).to include(users.sample[:email])
      end
    end

    shared_examples_for 'A searchable & orderable collection' do |search_keys|
      search_keys.each do |search_key|
        context "#{search_key} search & ordering" do
          it 'yields the correct matching results for search' do
            sample_user = users.sample
            get :index, params: { search_key => sample_user[search_key.to_sym], tenant_id: tenant_2.id }
            resp = JSON.parse(response.body)
            expect(resp['data']['clientData'].first[search_key.camelize(:lower)]).to eq(sample_user[search_key.to_sym])
          end

          it 'sorts the result according to the param provided' do
            expected_response = users.pluck(search_key.to_sym).sort.reverse
            get :index, params: { "#{search_key}_desc" => 'true', tenant_id: tenant_2.id }
            resp = JSON.parse(response.body)
            expect(resp['data']['clientData'].pluck(search_key.camelize(:lower))).to eq(expected_response)
          end
        end
      end
    end
    it_behaves_like 'A searchable & orderable collection', %w[first_name last_name email]
  end

  describe 'GET #show' do
    it 'returns an http status of success' do
      post :show, params: { tenant_id: tenant, id: user }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'post #create' do
    let(:user_attributes) { attributes_for(:user, email: 'email123@demo.com').deep_transform_keys { |k| k.to_s.camelize(:lower) } }
    let(:profile_attributes) { attributes_for(:profiles_profile).deep_transform_keys { |k| k.to_s.camelize(:lower) } }
    let(:attributes) { user_attributes.merge(profile_attributes) }

    it 'returns an http status of success' do
      post :create, params: { tenant_id: tenant, new_client: attributes.to_json }
      expect(response).to have_http_status(:success)
    end

    it 'creates the user' do
      post :create, params: { tenant_id: tenant, new_client: attributes.to_json }
      expect(User.last.email).to eq(attributes['email'])
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
        scope = ::Tenants::ScopeService.new(target: ::Tenants::User.find_by(legacy_id: user), tenant: ::Tenants::Tenant.find_by(legacy_id: tenant)).fetch
        scope[:base_pricing] = true

        allow(controller).to receive(:current_scope).and_return(scope)
      end

      it 'send the uploaded file to correct uploader' do
        expect(ExcelDataServices::Loaders::Uploader).to receive(:new).with(anything).and_return(uploader)

        post :agents, params: { tenant_id: tenant, file: file }
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { FactoryBot.create(:user, tenant: tenant) }

    it 'returns an http status of success' do
      delete :destroy, params: { tenant_id: tenant, id: user.id }
      expect(response).to have_http_status(:success)
    end

    it 'the removal of the user' do
      delete :destroy, params: { tenant_id: tenant, id: user.id }
      expect(User.find_by(id: user.id)).to be(nil)
    end
  end
end
