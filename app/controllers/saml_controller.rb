# frozen_string_literal: true

class SamlController < ApplicationController
  skip_before_action :require_non_guest_authentication!
  skip_before_action :require_authentication!

  def consume
    return error_redirect unless saml_response.present? && saml_response.is_valid?

    user = user_from_saml(response: saml_response, tenant_id: tenant.legacy_id)
    return error_redirect unless user.save

    auth = user.create_new_auth_token

    response_params = auth.merge(userId: user.id, tenantId: tenant.legacy_id)

    redirect_to generate_url(url_string: "https://#{request.host}/login/saml/success", params: response_params)
  end

  private

  def error_redirect
    redirect_to "https://#{request.host}/login/saml/error"
  end

  def user_from_saml(response:, tenant_id:)
    User.find_or_initialize_by(
      tenant_id: tenant_id,
      email: response.name_id,
      role: Role.find_by(name: 'shipper')
    ).tap do |user|
      user.first_name = response.attributes[:firstName]
      user.last_name = response.attributes[:lastName]
      user.phone = response.attributes[:phoneNumber]
    end
  end

  def tenant
    @tenant ||= begin
      domains = [
        request.host,
        ENV.fetch('DEFAULT_TENANT', 'demo.local')
      ]

      domains.each do |domain|
        tenants_domain = Tenants::Domain.where(':domain ~* domain', domain: domain).first
        return tenants_domain.tenant if tenants_domain
      end

      nil
    end
  end

  def saml_settings
    @saml_settings ||= begin
      tenant_saml_metadata = Tenants::SamlMetadatum.find_by(tenant: tenant)
      return if tenant_saml_metadata.blank?

      idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
      settings = idp_metadata_parser.parse(tenant_saml_metadata.content)

      settings.assertion_consumer_service_url = "https://#{request.host}/saml/consume"
      settings.name_identifier_format = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
      settings.authn_context = 'urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport'

      settings
    end
  end

  def generate_url(url_string:, params: {})
    URI(url_string).tap { |url| url.query = params.to_query }.to_s
  end

  def saml_response
    return false if saml_settings.blank?

    @saml_response ||= OneLogin::RubySaml::Response.new(saml_params, settings: saml_settings)
  end

  def saml_params
    params.require(:SAMLResponse)
  end
end
