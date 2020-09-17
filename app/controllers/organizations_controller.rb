# frozen_string_literal: true

class OrganizationsController < ApplicationController
  include Response

  skip_before_action :doorkeeper_authorize!
  skip_before_action :ensure_organization!, only: [:index]

  def index
    organizations = if Rails.env.production?
      []
    else
      Organizations::Organization.order(:slug).map { |t| {label: t.slug, value: t} }
    end

    response_handler(organizations)
  end

  def get_tenant
    @organization = Organizations::Organization.find_by(slug: params[:name])
    if @organization
      json_response(@organization, 200)
    else
      json_response({}, 400)
    end
  end

  deprecate :get_tenant, deprecator: ActiveSupport::Deprecation.new("", Rails.application.railtie_name)

  def fetch_scope
    response_handler(current_scope)
  end

  def show
    if organization
      theme = ::Organizations::Theme.find_by(organization_id: organization)
      auth_methods = ["password"].tap { |methods| methods << "saml" if saml_enabled? }
      response = organization.as_json.merge(
        theme: ::Organizations::ThemeDecorator.new(theme).legacy_format,
        scope: current_scope,
        subdomain: organization.slug,
        slug: organization.slug,
        auth_methods: auth_methods,
        name: theme.name,
        emails: theme.emails,
        phones: theme.phones,
        websites: theme.websites
      )
      response_handler(tenant: response)
    else
      response_handler(
        ApplicationError.new(
          http_code: 404,
          message: "Organization not found"
        )
      )
    end
  end

  def current
    response_handler(organization_id: organization_id)
  end

  private

  def organization_id
    return params[:id] if params[:id].present?

    super
  end

  def organization
    # Old code. not sure why params changes with environment? {H.Ezekiel}
    # tenant = Tenant.find_by(id: Rails.env.production? ? tenant_id : (params[:tenant_id] || params[:id]))
    @organization ||= Organizations::Organization.find_by(id: params[:id])
  end

  def saml_enabled?
    Organizations::SamlMetadatum.exists?(organization: organization)
  end
end
