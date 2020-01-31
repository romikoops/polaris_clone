# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SamlController, type: :controller do
  let!(:tenant) { create(:tenant, subdomain: 'test') }
  let!(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:saml_response) { build(:saml_response) }

  context 'with successful login' do
    before do
      create(:tenants_domain, domain: 'test.host', tenant: tenants_tenant)
      create(:tenants_saml_metadatum, tenant: tenants_tenant)

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
    before do
      create(:tenants_domain, domain: 'test.host', tenant: tenants_tenant)
      create(:tenants_saml_metadatum, tenant: tenants_tenant)
    end

    describe 'POST #consume' do
      it 'redirects to error url when the response is not valid' do
        post :consume, params: { SAMLResponse: saml_response }
        aggregate_failures do
          expect(response.location).to eq('https://test.host/login/saml/error')
        end
      end
    end
  end

  context 'when tenant is not found' do
    describe 'POST #consume' do
      it 'redirects to error url when the response is not valid' do
        post :consume, params: { SAMLResponse: saml_response }
        aggregate_failures do
          expect(response.location).to eq('https://test.host/login/saml/error')
        end
      end
    end
  end

  describe 'saml_settings' do
    before do
      create(:tenants_domain, domain: 'test.host', tenant: tenants_tenant)
      create(:tenants_saml_metadatum, tenant: tenants_tenant)
    end

    it 'returns the saml settings object' do
      controller = described_class.new
      controller.instance_variable_set(:@tenant, tenants_tenant)
      parser = controller.instance_eval { saml_settings }
      aggregate_failures do
        expect(parser).to be_a(OneLogin::RubySaml::Settings)
        expect(parser.authn_context).to eq('urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport')
        expect(parser.name_identifier_format).to eq('urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress')
        expect(parser.idp_entity_id).to eq('https://accounts.google.com/o/saml2?idpid=C03um7o22')
      end
    end
  end

end
