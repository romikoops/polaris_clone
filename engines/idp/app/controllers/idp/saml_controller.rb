module IDP
  class SamlController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:consume]

    def metadata
      render xml: OneLogin::RubySaml::Metadata.new.generate(saml_settings), content_type: "application/samlmetadata+xml"
    end

    def init
      redirect_to(OneLogin::RubySaml::Authrequest.new.create(saml_settings))
    end

    def consume
      return error_redirect unless saml_response.present? && saml_response.is_valid?

      ActiveRecord::Base.transaction do
        @response_params = SamlDataBuilder.new(saml_response: decorated_saml,
                                               organization_id: organization_id)
          .perform
      end

      redirect_to generate_url(url_string: "https://#{organization_domain}/login/saml/success",
                               params: @response_params)
    rescue ActiveRecord::RecordInvalid
      error_redirect
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

    def organization_id
      params[:id]
    end

    def saml_domain
      "idp.itsmycargo.shop"
    end

    def organization_domain
      Organizations::Domain.find_by!(default: true, organization_id: organization_id).domain
    end

    def generate_url(url_string:, params: {})
      URI(url_string).tap { |url| url.query = params.to_query }.to_s
    end

    def saml_response
      return if saml_settings.blank?

      @saml_response ||= OneLogin::RubySaml::Response.new(saml_params, settings: saml_settings)
    end

    def decorated_saml
      @decorated_saml ||= IDP::SamlResponseDecorator.new(saml_response)
    end

    def saml_params
      params.require(:SAMLResponse)
    end
  end
end
