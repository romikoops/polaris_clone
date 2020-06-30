# frozen_string_literal: true

class SamlController < ApplicationController
  skip_before_action :require_non_guest_authentication!
  skip_before_action :require_authentication!

  def init
    redirect_to(OneLogin::RubySaml::Authrequest.new.create(saml_settings))
  end

  def metadata
    render xml: OneLogin::RubySaml::Metadata.new.generate(saml_settings), content_type: 'application/samlmetadata+xml'
  end

  def consume
    return error_redirect unless saml_response.present? && saml_response.is_valid?

    user = user_from_saml(response: saml_response, tenant_id: tenant.legacy_id)
    return error_redirect unless user.save

    attach_to_groups(user: user, group_names: saml_response.attributes[:groups])
    create_or_update_user_profile(user: user, response: saml_response)
    response_params = user.create_new_auth_token.merge(userId: user.id, tenantId: tenant.legacy_id)

    redirect_to generate_url(url_string: "https://#{request.host}/login/saml/success", params: response_params)
  end

  private

  def error_redirect
    redirect_to "https://#{request.host}/login/saml/error"
  end

  def user_from_saml(response:, tenant_id:)
    User.find_or_initialize_by(
      tenant_id: tenant_id,
      email: response.attributes[:email] || response.name_id,
      role: Role.find_by(name: 'shipper')
    )
  end

  def tenant
    @tenant ||= begin
      ::Tenants::Domain.find_by(':domain ~* domain', domain: request.host)&.tenant
    end
  end

  def create_or_update_user_profile(user:, response:)
    tenants_user = Tenants::User.find_by(legacy_id: user.id)
    Profiles::ProfileService.create_or_update_profile(user: tenants_user,
                                                      first_name: response.attributes[:firstName],
                                                      last_name: response.attributes[:lastName],
                                                      phone: response.attributes[:phone])
  end

  def saml_settings
    @saml_settings ||= begin
      tenant_saml_metadata = Tenants::SamlMetadatum.find_by(tenant: tenant)
      return if tenant_saml_metadata.blank?

      idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
      settings = idp_metadata_parser.parse(tenant_saml_metadata.content)

      settings.assertion_consumer_service_url = "https://#{request.host}/saml/consume"
      settings.sp_entity_id = "https://#{request.host}/saml/metadata"
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

  def attach_to_groups(user:, group_names:)
    return if group_names.blank?

    tenants_user = Tenants::User.find_by(legacy_id: user.id)
    groups = Tenants::Group.where(name: group_names, tenant: tenant)
    return if groups.empty?

    Tenants::Membership.where(member: tenants_user).where.not(group: groups)&.destroy_all
    groups.each { |group| Tenants::Membership.find_or_create_by(member: tenants_user, group: group) }
  end
end
