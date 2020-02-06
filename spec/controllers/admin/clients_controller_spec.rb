# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ClientsController do
  let(:tenant) { FactoryBot.create(:tenant) }
  let(:user) { FactoryBot.create(:user, tenant: tenant) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns an http status of success' do
      get :index, params: { tenant_id: tenant }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'returns an http status of success' do
      post :show, params: { tenant_id: tenant, id: user }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'post #create' do
    let(:attributes) { attributes_for(:user, email: 'email123@demo.com').deep_transform_keys { |k| k.to_s.camelize(:lower) } }

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
        scope =  ::Tenants::ScopeService.new(target: ::Tenants::User.find_by(legacy_id: user), tenant: ::Tenants::Tenant.find_by(legacy_id: tenant)).fetch
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
