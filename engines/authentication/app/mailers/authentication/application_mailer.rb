# frozen_string_literal: true

module Authentication
  class ApplicationMailer < ActionMailer::Base
    default from: "no-reply@itsmycargo.com"

    def default_domain
      current_organization.domains.find_by(default: true)&.domain
    end

    def set_organization(organization_id:)
      ::Organizations.current_id = organization_id
    end

    def current_organization
      @current_organization ||= Organizations::Organization.current
    end

    def set_theme
      @org_theme = ::Organizations::ThemeDecorator.new(current_organization.theme)
      @theme = @org_theme.legacy_format
      @primary_color = @theme.dig("colors", "primary")
      @email_logo = @org_theme.email_logo
    end
  end
end
