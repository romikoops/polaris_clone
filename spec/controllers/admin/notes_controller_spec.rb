# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::NotesController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:role) { FactoryBot.create(:legacy_role, name: 'Admin') }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, role: role) }

  before do
    allow(controller).to receive(:require_authentication!).and_return(true)
    allow(controller).to receive(:require_non_guest_authentication!).and_return(true)
    allow(controller).to receive(:require_login_and_role_is_admin).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_tenant).and_return(tenant)
  end

  describe 'POST #upload' do
    before do
      allow(Legacy::File).to receive(:create!)
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
