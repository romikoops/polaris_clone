# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyTenants
  RSpec.describe TenantsController, type: :controller do
    routes { Engine.routes }
    render_views

    before do
      allow_any_instance_of(AdmiraltyAuth::AuthorizedController).to receive(:authenticate!).and_return(true)
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
                                         cargo_class: 'lcl',
                                         aggregate: false,
                                         width: 0.59e3,
                                         length: 0.2342e3,
                                         height: 0.228e3,
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

    describe 'GET #new' do
      it 'renders page' do
        get :new

        aggregate_failures do
          expect(response).to be_successful
          expect(response.body).to match(/class="new_tenant"/im)
        end
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
      let(:tenant_params) { tenant.attributes.slice('name', 'slug').merge(scope: { foo: true }.to_json, saml_metadatum: { content: '' }) }
      let(:updated_max_bundle) { { max_bundle.id => { width: 10 } } }

      it 'renders page' do
        patch :update, params: { id: tenant.id, tenant: tenant_params, max_dimensions: updated_max_bundle }

        expect(response).to redirect_to("/tenants/#{tenant.id}")
        expect(::Tenants::Tenant.find(tenant.id).scope.content).to eq('foo' => true)
        expect(::Legacy::MaxDimensionsBundle.find(max_bundle.id).width).to eq(10)
      end
    end

    describe 'POST #create' do
      let(:tenant_params) do
        {
          name: 'Test',
          slug: 'tester',
          theme: {
            primary_color: '#000001',
            secondary_color: '#000002',
            bright_primary_color: '#000003',
            bright_secondary_color: '#000004'
          },
          scope: {
            base_pricing: true
          }.to_json.to_s
        }
      end

      it 'renders page' do
        post :create, params: { tenant: tenant_params }
        expect(::Tenants::Tenant.find_by(slug: 'tester').scope.content).to eq('base_pricing' => true)
      end

      it 'fails to create tenant' do
        FactoryBot.create(:tenants_tenant, slug: 'tester')
        post :create, params: { tenant: tenant_params }

        aggregate_failures do
          expect(response).to be_successful
          expect(response.body).to match(/Slug has already been taken/im)
        end
      end
    end
  end
end
