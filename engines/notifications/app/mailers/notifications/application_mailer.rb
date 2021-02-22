# frozen_string_literal: true
module Notifications
  class ApplicationMailer < ActionMailer::Base
    default from: "no-reply@itsmycargo.shop"
    layout "notifications/mailer"

    def shop_url(path = "")
      domain = current_organization.domains.find(&:default).domain
      URI.join("https://#{domain}", path)
    end
    helper_method :shop_url

    def company_name
      current_organization.theme.name
    end
    helper_method :company_name

    def current_organization
      params[:organization]
    end
    helper_method :current_organization

    def current_scope(user:)
      OrganizationManager::ScopeService.new(target: user, organization: current_organization).fetch
    end
    helper_method :current_scope

    def organization_from_email(mode_of_transport:)
      emails = current_organization.theme.emails
      emails.dig("sales", mode_of_transport) ||
        emails.dig("sales", "general") ||
        "no-reply@itsmycargo.shop"
    end
    helper_method :organization_from_email
  end
end
