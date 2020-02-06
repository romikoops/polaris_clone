# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::MarginsController, type: :controller do
  before do
    expect_any_instance_of(described_class).to receive(:require_authentication!).and_return(true)
    expect_any_instance_of(described_class).to receive(:require_non_guest_authentication!).and_return(true)
    expect_any_instance_of(described_class).to receive(:require_login_and_role_is_admin).and_return(true)
    expect_any_instance_of(described_class).to receive(:current_tenant).at_least(:once).and_return(double('Tenant', scope: {}, subdomain: 'test', id: 1))
    expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(double('User', guest: false, email: 'test@test.com', id: 1, agency_id: nil, agency: nil, tenant: nil, groups: nil, company: nil, scope: nil, sandbox: nil))
  end

  describe 'POST #upload' do
    before do
      expect(Document).to receive(:create!)
    end

    it 'returns error with messages when an error is raised' do
      post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1 }
      json_response = JSON.parse(response.body)
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response['data']).not_to be_empty
      end
    end
  end
end
