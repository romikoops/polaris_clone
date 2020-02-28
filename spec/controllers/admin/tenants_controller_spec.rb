# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TenantsController, type: :controller do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }

  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:json_response) { JSON.parse(response.body) }

  before do
    allow(controller).to receive(:require_authentication!).and_return(true)
    allow(controller).to receive(:require_non_guest_authentication!).and_return(true)
    allow(controller).to receive(:require_login_and_role_is_admin).and_return(true)
    allow(controller).to receive(:current_tenant).at_least(:once).and_return(tenant)
    allow(controller).to receive(:current_user).at_least(:once).and_return(user)
  end

  describe 'POST #update' do
    let(:email_params) { { 'sales' => { 'ocean' => 'new_ocean@sales.com' } } }

    it 'returns http success' do
      put :update, params: { tenant_id: tenant.id, id: tenant.id, tenant: { emails: email_params } }
      expect(response).to have_http_status(:success)
    end

    it 'updates tenant emails' do
      put :update, params: { tenant_id: tenant.id, id: tenant.id, tenant: { emails: email_params } }
      expect(tenant.emails).to match email_params
    end
  end
end
