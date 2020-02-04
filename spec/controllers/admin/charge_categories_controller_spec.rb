# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ChargeCategoriesController, type: :controller do
  describe 'POST #upload' do
    before do
      expect_any_instance_of(described_class).to receive(:require_authentication!).and_return(true)
      expect_any_instance_of(described_class).to receive(:require_non_guest_authentication!).and_return(true)
      expect_any_instance_of(described_class).to receive(:require_login_and_role_is_admin).and_return(true)
      expect_any_instance_of(described_class).to receive(:current_tenant).at_least(:once).and_return(double('Tenant', scope: {}, subdomain: 'test', id: 1))
      expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(double('User', guest: false, email: 'test@test.com', id: 1, agency_id: nil, agency: nil, tenant: nil, groups: nil, company: nil, scope: nil, sandbox: nil))
      expect(Document).to receive(:create!)
    end

    it 'returns error with messages when an error is raised' do
      post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1 }
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json_response['data']).not_to be_empty
    end
  end

  describe 'GET #download' do
    let(:tenant) { create(:tenant) }

    before do
      create(:tenants_scope, target: Tenants::Tenant.find_by(legacy_id: tenant.id), content: { 'base_pricing' => true })
      expect_any_instance_of(described_class).to receive(:require_authentication!).and_return(true)
      expect_any_instance_of(described_class).to receive(:require_non_guest_authentication!).and_return(true)
      expect_any_instance_of(described_class).to receive(:require_login_and_role_is_admin).and_return(true)
      expect_any_instance_of(described_class).to receive(:current_tenant).at_least(:once).and_return(tenant)
      expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(double('User', guest: false, email: 'test@test.com', id: 1, agency_id: nil, agency: nil, tenant: nil, groups: nil, company: nil, scope: nil, sandbox: nil))
    end

    it 'returns error with messages when an error is raised' do
      get :download, params: { tenant_id: tenant.id, options: { mot: 'ocean' } }
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json_response.dig('data', 'url')).to include('demo__charge_categories.xlsx')
    end
  end
end
