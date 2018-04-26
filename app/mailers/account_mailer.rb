class AccountMailer < Devise::Mailer
	default template_path: 'devise/mailer'
  layout 'mailer'
  include Devise::Controllers::UrlHelpers

  ### TBD ### Try this later ### helper :application
  add_template_helper(ApplicationHelper)

  def confirmation_instructions(record, token, opts={})
    base_url = case Rails.env
      when 'production'  then "http://#{record.tenant.subdomain}.itsmycargo.com/"
      when 'development' then "http://localhost:8080/"
      when 'test'        then "http://localhost:8080/"
      end

    # attachments.inline['logo.png'] = open(tenant.theme["logoLarge"]).read

    # headers["Custom-header"] = "Some Headers"
    # opts[:reply_to] = 'example@email.com'
    
    opts[:subject] = "ItsMyCargo Account Email Confirmation"
    @redirect_url = base_url + "account"

    super
  end
end
