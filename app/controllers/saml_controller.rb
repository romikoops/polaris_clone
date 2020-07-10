# frozen_string_literal: true

class SamlController < ApplicationController
  skip_before_action :doorkeeper_authorize!
  before_action :set_current_organization

  def init
    redirect_to(OneLogin::RubySaml::Authrequest.new.create(saml_settings))
  end

  def metadata
    render xml: OneLogin::RubySaml::Metadata.new.generate(saml_settings), content_type: 'application/samlmetadata+xml'
  end

  def consume
    return error_redirect unless saml_response.present? && saml_response.is_valid?

    user = user_from_saml(response: saml_response, organization_id: organization.id)

    return error_redirect unless user.save

    attach_to_groups(user: user, group_names: saml_response.attributes[:groups])
    create_or_update_user_profile(user: user, response: saml_response)

    token = generate_token_for(user: user, scope: 'public')
    token_header = Doorkeeper::OAuth::TokenResponse.new(token).body
    response_params = token_header.merge(userId: user.id, organizationId: organization.id)
    redirect_to generate_url(url_string: "https://#{request.host}/login/saml/success", params: response_params)
  end

  private

  def error_redirect
    redirect_to "https://#{request.host}/login/saml/error"
  end

  def user_from_saml(response:, organization_id:)
    Organizations::User.find_or_initialize_by(
      organization_id: organization_id,
      email: response.attributes[:email] || response.name_id
    )
  end

  def organization
    @organization ||= ::Organizations::Organization.find(organization_id)
  end

  def create_or_update_user_profile(user:, response:)
    Profiles::ProfileService.create_or_update_profile(user: user,
                                                      first_name: response.attributes[:firstName],
                                                      last_name: response.attributes[:lastName],
                                                      phone: response.attributes[:phone])
  end

  def saml_settings
    @saml_settings ||= begin
      organization_saml_metadata = Organizations::SamlMetadatum.find_by(organization_id: organization_id)
      return if organization_saml_metadata.blank?

      idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
      settings = idp_metadata_parser.parse(organization_saml_metadata.content)

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

    groups = Groups::Group.where(name: group_names, organization: organization)
    return if groups.empty?

    Groups::Membership.where(member: user).where.not(group: groups)&.destroy_all
    groups.each { |group| Groups::Membership.find_or_create_by(member: user, group: group) }
  end

  def set_current_organization
    Organizations.current_id = organization.id
  end
end
