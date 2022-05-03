# frozen_string_literal: true

module IDP
  class SamlController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:consume]
    before_action :set_current_organization_id, only: [:consume]

    def metadata
      render xml: OneLogin::RubySaml::Metadata.new.generate(saml_settings), content_type: "application/samlmetadata+xml"
    end

    def init
      session[:redirect_url] = request.referrer
      session[:application_id] = referrer_application_id
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

      @response_params = SamlDataBuilder.new(saml_response: decorated_saml, organization_id: organization_id, application_id: session[:application_id]).perform

      if @response_params.errors.any?
        register_errors_and_redirect(errors: @response_params.errors)
        return
      end

      publish_successful_login_event

      redirect_to generate_url(
        url_string: URI.join(organization_url, "login/saml/success"),
        params: @response_params.data
      )
    end

    private

    def referrer_application_id
      [
        Organizations::Domain.find_by(domain: referrer_host),
        Organizations::Domain.find_by("? ILIKE domain", referrer_host)
      ].compact.map(&:application_id).first
    end

    def referrer_host
      @referrer_host ||= URI(request.referrer.to_s).host
    end

    def error_redirect
      redirect_to URI.join(organization_url, "login/saml/error")
    end

    def saml_metadata
      @saml_metadata ||= Organizations::SamlMetadatum.find_by(organization_id: organization_id)
    end

    def saml_settings
      @saml_settings ||= if saml_metadata.present?
        settings = OneLogin::RubySaml::IdpMetadataParser.new.parse(saml_metadata.content)

        settings.assertion_consumer_service_url = consume_saml_url
        settings.sp_entity_id = metadata_saml_url
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

    def organization_url
      session[:redirect_url] || "https://#{organization_domain}/"
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
        url_string: URI.join(organization_url, "login/saml/error"),
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
