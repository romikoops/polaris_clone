# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SamlController, type: :controller do
  let(:tenant) { create(:tenant, subdomain: 'test') }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:saml_response) { build(:saml_response) }
  let!(:role) { create(:role, name: 'shipper') }
  let(:user) { create(:legacy_user, tenant: tenant, role: role) }
  let!(:tenants_domain) { create(:tenants_domain, domain: 'test.host', tenant: tenants_tenant) }
  let!(:default_group) { create(:tenants_group, tenant: tenants_tenant, name: 'default') }

  before do
    create(:tenants_saml_metadatum, tenant: tenants_tenant)
  end

  describe 'GET init' do
    it 'redirects to SAML login' do
      get :init

      expect(response.location).to start_with('https://accounts.google.com/o/saml2')
    end
  end

  describe 'GET metadata' do
    it 'return correct metadata' do
      get :metadata

      expect(response.body).to include("entityID='https://#{tenants_domain.domain}/saml/metadata'")
    end
  end

  describe 'POST #consume' do
    let(:one_login) { instance_double('OneLogin::RubySaml::Response', is_valid?: true) }
    let(:attributes) { { firstName: 'Test', lastName: 'User', phoneNumber: 123_456_789 } }

    before do
      create(:role, name: 'shipper')
      allow(one_login).to receive(:is_valid?).and_return(true)
      allow(one_login).to receive(:name_id).and_return('test@itsmycargo.com')
      allow(one_login).to receive(:attributes).and_return(attributes)
      allow(controller).to receive(:saml_response).and_return(one_login)
    end

    context 'with successful login' do
      it 'returns an http status of success' do
        post :consume, params: { SAMLResponse: {} }
        aggregate_failures do
          expect(response.status).to eq(302)
          redirect_location = response.location
          response_params = Rack::Utils.parse_nested_query(redirect_location.split('success?').second)
          expect(response_params.keys).to match_array(%w[access-token client expiry tenantId token-type uid userId])
          expect(response_params['tenantId']).to eq(tenant.id.to_s)
        end
      end
    end

    context 'with successful login and existing user (no groups)' do
      let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }

      before do
        allow(one_login).to receive(:name_id).and_return(user.email)
        post :consume, params: { SAMLResponse: {} }
      end

      it 'returns an http status of success' do
        aggregate_failures do
          expect(response.status).to eq(302)
          redirect_location = response.location
          response_params = Rack::Utils.parse_nested_query(redirect_location.split('success?').second)
          expect(response_params.keys).to match_array(%w[access-token client expiry tenantId token-type uid userId])
          expect(response_params['tenantId']).to eq(tenant.id.to_s)
        end
      end

      it 'attaches the user to the default group' do
        aggregate_failures do
          expect(tenants_user.groups).to match_array([default_group])
        end
      end
    end

    context 'with successful login and group param present' do
      let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
      let!(:group) { FactoryBot.create(:tenants_group, name: 'Test Group', tenant: tenants_tenant) }
      let(:attributes) { { firstName: 'Test', lastName: 'User', phoneNumber: 123_456_789, groups: [group.name] } }

      before do
        allow(one_login).to receive(:name_id).and_return(user.email)
        post :consume, params: { SAMLResponse: {} }
      end

      it 'returns an http status of success' do
        aggregate_failures do
          expect(response.status).to eq(302)
          redirect_location = response.location
          response_params = Rack::Utils.parse_nested_query(redirect_location.split('success?').second)
          expect(response_params.keys).to match_array(%w[access-token client expiry tenantId token-type uid userId])
          expect(response_params['tenantId']).to eq(tenant.id.to_s)
        end
      end

      it 'attaches the user to the target group' do
        aggregate_failures do
          expect(tenants_user.groups).to match_array([group])
        end
      end
    end

    context 'with successful login and group param and existing present' do
      let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
      let!(:group) { FactoryBot.create(:tenants_group, name: 'Test Group', tenant: tenants_tenant) }
      let!(:group_2) { FactoryBot.create(:tenants_group, name: 'Test Group 2', tenant: tenants_tenant) }
      let!(:group_3) { FactoryBot.create(:tenants_group, name: 'Test Group 3', tenant: tenants_tenant) }
      let(:attributes) {
        {
          firstName: 'Test',
          lastName: 'User',
          phoneNumber: 123_456_789,
          groups: [group.name, group_2.name]
        }
      }

      before do
        FactoryBot.create(:tenants_membership, group: group_3, member: tenants_user)
        allow(one_login).to receive(:name_id).and_return(user.email)
        post :consume, params: { SAMLResponse: {} }
      end

      it 'returns an http status of success' do
        aggregate_failures do
          expect(response.status).to eq(302)
          redirect_location = response.location
          response_params = Rack::Utils.parse_nested_query(redirect_location.split('success?').second)
          expect(response_params.keys).to match_array(%w[access-token client expiry tenantId token-type uid userId])
          expect(response_params['tenantId']).to eq(tenant.id.to_s)
        end
      end

      it 'attaches the user to the target group' do
        aggregate_failures do
          expect(tenants_user.groups).to match_array([group, group_2])
        end
      end
    end
  end

  context 'with unsuccessful login' do
    describe 'POST #consume (failed login)' do
      it 'redirects to error url when the response is not valid' do
        post :consume, params: { SAMLResponse: saml_response }

        expect(response.location).to eq('https://test.host/login/saml/error')
      end
    end
  end

  context 'when tenant is not found' do
    describe 'POST #consume (no tenant)' do
      it 'redirects to error url when the response is not valid' do
        post :consume, params: { SAMLResponse: saml_response }

        expect(response.location).to eq('https://test.host/login/saml/error')
      end
    end
  end
end
