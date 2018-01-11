class ApplicationMailer < ActionMailer::Base
	default from: "itsmycargodev@gmail.com"
	layout 'mailer'

	def beta_prospect_mail(prospect_name, email, company, phone)
	  @prospect_name = prospect_name
	  @email = email
	  @company = company
	  @phone = phone
	  mail(to: "support@itsmycargo.com", subject: 'ItsMyCargo Beta Prospect!') do |format|
	    format.text 
	  end
	end
end
