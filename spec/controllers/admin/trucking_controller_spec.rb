# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TruckingController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:hub) { FactoryBot.create(:legacy_hub, tenant: tenant) }
  let(:json_response) { JSON.parse(response.body) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_tenant).and_return(tenant)
    allow(controller).to receive(:require_login_and_role_is_admin).and_return(true)
  end

  describe 'POST #overwrite_zonal_trucking_by_hub' do
    before do
      allow(Legacy::File).to receive(:create!)
      inserter_double = instance_double('Trucking::Excel::Inserter', perform: true)
      allow(Trucking::Excel::Inserter).to receive(:new).and_return(inserter_double)
      post :overwrite_zonal_trucking_by_hub, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1, group: 'all', id: hub.id }
    end

    it 'returns error with messages when an error is raised' do
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response['data']).to be_truthy
      end
    end
  end
end
