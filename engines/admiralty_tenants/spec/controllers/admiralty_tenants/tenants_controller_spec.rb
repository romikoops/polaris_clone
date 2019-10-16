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

        ::Tenants::Tenant.find_by(legacy_id: tenant.id)
      end
    end

    let!(:scopes) do
      tenants.each do |tenant|
        ::Tenants::Scope.create(target: ::Tenants::Tenant.find_by(legacy_id: tenant.id), content: { closed_shop: false })
      end
    end

    let(:tenant) { tenants.sample }

    let!(:max_bundle) do
        Legacy::MaxDimensionsBundle.create(mode_of_transport: 'general',
                                           tenant_id: tenant.legacy_id,
                                           aggregate: false,
                                           dimension_x: 0.59e3,
                                           dimension_y: 0.2342e3,
                                           dimension_z: 0.228e3,
                                           payload_in_kg: 0.2177e5,
                                           chargeable_weight: 0.2177e5)
    end

    describe 'GET #index' do
      it 'renders page' do
        get :index

        expect(response).to be_successful
        expect(response.body).to match(/<td>#{tenants.sample.slug}/im)
      end
    end

    describe 'GET #show' do
      it 'renders page' do
        get :show, params: { id: tenant.id }

        expect(response).to be_successful
        expect(response.body).to match(/<dd.*#{tenant.slug}/im)
      end
    end

    describe 'GET #edit' do
      it 'renders page' do
        get :edit, params: { id: tenant.id }

        expect(response).to be_successful
        expect(response.body).to match(/value="#{tenant.slug}"/im)
      end
    end

    describe 'PATCH #update' do
      let(:tenant_params) { tenant.attributes.slice('name', 'slug').merge(scope: { foo: true }.to_json) }
      let(:updated_max_bundle) { { max_bundle.id => { dimension_x: 10 } } }
      it 'renders page' do
        patch :update, params: { id: tenant.id, tenant: tenant_params, max_dimensions: updated_max_bundle }

        expect(response).to redirect_to("/tenants/#{tenant.id}")
        expect(::Tenants::Tenant.find(tenant.id).legacy.tenants_scope).to eq('foo' => true)
        expect(::Legacy::MaxDimensionsBundle.find(max_bundle.id).dimension_x).to eq(10)
      end
    end
  end
end
