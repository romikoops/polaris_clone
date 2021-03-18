# frozen_string_literal: true
module IDP
  class SamlController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:consume]
    before_action :set_current_organization_id, only: [:consume]

    def metadata
      render xml: OneLogin::RubySaml::Metadata.new.generate(saml_settings), content_type: "application/samlmetadata+xml"
    end

    def init
      redirect_to(OneLogin::RubySaml::Authrequest.new.create(saml_settings))
    end

    def consume
      if organization.blank?
        render plain: "Organization not found"
        return
      end

      if saml_settings.blank?
        register_errors_and_redirect(errors: ["SAML settings not found"])
        return
      end

      unless saml_response.is_valid?
       register_errors_and_redirect(errors: saml_response.errors)
       return
      end

      @response_params = SamlDataBuilder.new(saml_response: decorated_saml, organization_id: organization_id).perform

      if @response_params.errors.any?
        register_errors_and_redirect(errors: @response_params.errors)
        return
      end

      redirect_to generate_url(
        url_string: "https://#{organization_domain}/login/saml/success",
        params: @response_params.data)

      publish_successful_login_event
    end

    private

    def error_redirect
      redirect_to "https://#{organization_domain}/login/saml/error"
    end

    def saml_settings
      @saml_settings ||= begin
        organization_saml_metadata = Organizations::SamlMetadatum.find_by(organization_id: organization_id)
        return if organization_saml_metadata.blank?

        idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
        settings = idp_metadata_parser.parse(organization_saml_metadata.content)

        settings.assertion_consumer_service_url = "https://#{saml_domain}/saml/#{organization_id}/consume"
        settings.sp_entity_id = "https://#{saml_domain}/saml/#{organization_id}/metadata"
        settings.name_identifier_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
        settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

        settings
      end
    end

    def organization
      Organizations::Organization.find_by(id: organization_id)
    end

    def organization_id
      params[:id]
    end

    def saml_domain
      "idp.itsmycargo.shop"
    end

    def organization_domain
      Organizations::Domain.find_by(default: true, organization_id: organization_id).domain
    end

    def generate_url(url_string:, params: {})
      URI(url_string).tap { |url| url.query = params.to_query }.to_s
    end

    def saml_response
      @saml_response ||= OneLogin::RubySaml::Response.new(saml_params, settings: saml_settings)
    end

    def decorated_saml
      @decorated_saml ||= IDP::SamlResponseDecorator.new(saml_response)
    end

    def saml_params
      params.require(:SAMLResponse)
    end

    def set_current_organization_id
      Organizations.current_id = organization_id
    end

    def register_errors_and_redirect(errors:)
      publish_error_event(errors)

      redirect_to generate_url(
        url_string: "https://#{organization_domain}/login/saml/error",
        params: { errors: errors }
      )
    end

    def publish_error_event(errors)
      Rails.configuration.event_store.publish(
        IDP::SamlUnsuccessfulLogin.new(
          data: {
            params: params,
            error_messages: errors
          }
        ),
        stream_name: "Organization$#{organization_id}"
      )
    end

    def publish_successful_login_event
      Rails.configuration.event_store.publish(
        IDP::SamlSuccessfulLogin.new(
          data: {
            params: params
          }
        ),
        stream_name: "Organization$#{organization_id}"
      )
    end
  end
end
