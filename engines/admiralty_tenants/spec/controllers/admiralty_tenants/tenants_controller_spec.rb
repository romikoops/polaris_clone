# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyTenants
  RSpec.describe TenantsController, type: :controller do
    routes { Engine.routes }
    render_views

    before do
      allow_any_instance_of(AdmiraltyAuth::AuthorizedController).to receive(:authenticate_user!).and_return(true)
    end

    let!(:tenants) do
      Array.new(5) do |i|
        tenant = ::Legacy::Tenant.create(subdomain: "demo#{i}", scope: { closed_shop: false })
        ::Tenants::Scope.create(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id), content: { closed_shop: false })
        
        tenant
      end
    end
    let!(:scopes) do
      tenants.each do |tenant|
        ::Tenants::Scope.create(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id), content: { closed_shop: false })
      end
    end

    let(:tenant) { tenants.sample }

    describe 'GET #index' do
      it 'renders page' do
        get :index

        expect(response).to be_successful
        expect(response.body).to match(/<td>#{tenants.sample.subdomain}/im)
      end
    end

    describe 'GET #show' do
      it 'renders page' do
        get :show, params: { id: tenant.id }

        expect(response).to be_successful
        expect(response.body).to match(/<dd.*#{tenant.subdomain}\.itsmycargo\.com/im)
      end
    end

    describe 'GET #edit' do
      it 'renders page' do
        get :edit, params: { id: tenant.id }

        expect(response).to be_successful
        expect(response.body).to match(/value="#{tenant.subdomain}"/im)
      end
    end

    describe 'PATCH #update' do
      let(:tenant_params) { tenant.attributes.slice('name', 'subdomain').merge(scope: { foo: true }.to_json) }

      it 'renders page' do
        patch :update, params: { id: tenant.id, tenant: tenant_params }

        expect(response).to redirect_to("/tenants/#{tenant.id}")
        expect(::Legacy::Tenant.find(tenant.id).tenants_scope).to eq('foo' => true)
      end
    end
  end
end
