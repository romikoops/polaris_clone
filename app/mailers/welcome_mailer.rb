# frozen_string_literal: true

class WelcomeMailer < ApplicationMailer
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def welcome_email(user)
    @user = user
    tenant = @user.tenant
    @theme = tenant.theme
    @content = Content.where(tenant_id: tenant.id, component: 'WelcomeMail')
    mail(
      to: email,
      subject: "Quotation for #{@shipment.imc_reference}"
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

  def generate_and_upload_quotation(quotes)
    quotation = PdfHandler.new(
      layout:      'pdfs/simple.pdf.html.erb',
      template:    'shipments/pdfs/quotations.pdf.erb',
      margin:      { top: 15, bottom: 5, left: 8, right: 8 },
      shipment:    @shipment,
      shipments:   @shipments,
      quotation:   @quotation,
      quotes:      quotes,
      color:       @user.tenant.theme['colors']['primary'],
      name:        'quotation',
      remarks:    Remark.where(tenant_id: @user.tenant_id)
    )
    quotation.generate
  end
end
