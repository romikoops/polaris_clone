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
  end
end
