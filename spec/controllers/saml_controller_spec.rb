# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SamlController, type: :controller do
  let(:tenant) { create(:tenant, subdomain: 'test') }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:saml_response) { build(:saml_response) }

  let!(:tenants_domain) { create(:tenants_domain, domain: 'test.host', tenant: tenants_tenant) }
  let!(:saml_metadata) { create(:tenants_saml_metadatum, tenant: tenants_tenant) }


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

  context 'with successful login' do
    before do
      create(:tenants_group, tenant: tenants_tenant, name: 'default')
      create(:role, name: 'shipper')
      one_login = double('OneLogin::RubySaml::Response', is_valid?: true)
      allow(one_login).to receive(:is_valid?).and_return(true)
      allow(one_login).to receive(:name_id).and_return('test@itsmycargo.com')
      allow(one_login).to receive(:attributes).and_return(firstName: 'Test', lastName: 'User', phoneNumber: 123_456_789)
      allow_any_instance_of(described_class).to receive(:saml_response).and_return(one_login)
    end

    describe 'POST #consume' do
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
  end

  context 'with unsuccessful login' do
    describe 'POST #consume' do
      it 'redirects to error url when the response is not valid' do
        post :consume, params: { SAMLResponse: saml_response }

        expect(response.location).to eq('https://test.host/login/saml/error')
      end
    end
  end

  context 'when tenant is not found' do
    describe 'POST #consume' do
      it 'redirects to error url when the response is not valid' do
        post :consume, params: { SAMLResponse: saml_response }

        expect(response.location).to eq('https://test.host/login/saml/error')
      end
    end
  end
end
