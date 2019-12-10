# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyReports
  RSpec.describe StatsController, type: :controller do
    routes { Engine.routes }
    render_views

    before do
      allow_any_instance_of(AdmiraltyAuth::AuthorizedController).to receive(:authenticate_user!).and_return(true)
    end

    let!(:tenants) do
      [
        ::Legacy::Tenant.create(name: 'Demo1', subdomain: 'demo1', scope: { 'open_quotation_tool' => true }),
        ::Legacy::Tenant.create(name: 'Demo2', subdomain: 'demo2', scope: { 'open_quotation_tool' => false })
      ]
    end
    let!(:tenants_tenants_true) { ::Tenants::Tenant.find_by(slug: 'demo1') }
    let!(:tenants_tenants_false) { ::Tenants::Tenant.find_by(slug: 'demo2') }

    let!(:scopes) do
      [
        ::Tenants::Scope.create(target: tenants_tenants_true, content: { 'open_quotation_tool' => true }),
        ::Tenants::Scope.create(target: tenants_tenants_false, content: { 'open_quotation_tool' => false })
      ]
    end

    describe 'GET #index' do
      it 'renders page' do
        get :download
        expect(response).to be_successful
      end
    end
  end
end
