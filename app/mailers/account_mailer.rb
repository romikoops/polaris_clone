class AccountMailer < Devise::Mailer
	default template_path: 'devise/mailer'
  layout 'mailer'
  helper :application
  include Devise::Controllers::UrlHelpers


  def confirmation_instructions(record, token, opts={})
    tenant = record.tenant

    base_url = case Rails.env
      when 'production'  then "http://#{tenant.subdomain}.itsmycargo.com/"
      when 'development' then "http://localhost:8080/"
      when 'test'        then "http://localhost:8080/"
      end

    attachments.inline['logo.png'] = open(tenant.theme["logoLarge"]).read

    
    opts[:subject] = "ItsMyCargo Account Email Confirmation"
    @redirect_url = base_url + "account"

    # headers["Custom-header"] = "Some Headers"
    # opts[:reply_to] = 'example@email.com'
    super
  end
end
