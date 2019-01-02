# frozen_string_literal: true

class ShipmentMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def tenant_notification(user, shipment) # rubocop:disable Metrics/AbcSize
    @user = user
    tenant = user.tenant
    @shipment = shipment
    @scope = tenant.scope
    base_url =
      case Rails.env
      when 'production'  then "https://#{@shipment.tenant.subdomain}.itsmycargo.com/"
      when 'review'      then ENV['REVIEW_URL']
      when 'development' then 'http://localhost:8080/'
      when 'test'        then 'http://localhost:8080/'
      end

    @redirects_base_url = base_url + "redirects/shipments/#{@shipment.id}?action="

    @mot =
      case @shipment.mode_of_transport
      when 'ocean' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-01.png'
      when 'air' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-02.png'
      when 'truck' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-03.png'
      when 'rail' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-04.png'
      end

    create_pdf_attachment(@shipment)
    attachments.inline['logo.png'] = URI.open(tenant.theme['logoLarge']).read
    attachments.inline['icon.png'] = URI.open(@mot).read
    mail_options = {
      from: Mail::Address.new("no-reply@#{@user.tenant.subdomain}.#{Settings.emails.domain}")
                         .tap { |a| a.display_name = 'ItsMyCargo Bookings' }.format,
      reply_to: 'support@itsmycargo.com',
      to: mail_target_interceptor(@user, tenant.email_for(:sales, shipment.mode_of_transport)),
      subject: "Your booking through #{tenant.name}"
    }

    mail(mail_options, &:html)
  end

  def shipper_notification(user, shipment) # rubocop:disable Metrics/AbcSize
    @user = user
    @shipment = shipment
    @scope = @user.tenant.scope

    @mot =
      case @shipment.mode_of_transport
      when 'ocean' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-01.png'
      when 'air' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-02.png'
      when 'truck' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-03.png'
      when 'rail' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-04.png'
      end

    create_pdf_attachment(@shipment)
    attachments.inline['logo.png']       = URI.open(tenant.theme['logoLarge']).read
    attachments.inline['logo_small.png'] = URI.try(:open, tenant.theme['logoSmall']).try(:read)
    attachments.inline['icon.png'] = URI.open(@mot).read
    mail_options = {
      from: Mail::Address.new("no-reply@#{@user.tenant.subdomain}.#{Settings.emails.domain}")
                         .tap { |a| a.display_name = @user.tenant.name }.format,
      reply_to: @user.tenant.emails.dig('support', 'general'),
      to: mail_target_interceptor(@user, @user.email.blank? ? 'itsmycargodev@gmail.com' : @user.email),
      bcc: [Settings.emails.booking],
      subject: "Your booking through #{@user.tenant.name}"
    }

    mail(mail_options, &:html)
  end

  def shipper_confirmation(user, shipment) # rubocop:disable Metrics/AbcSize
    @user = user
    @shipment = shipment
    @scope = tenant.scope

    @mot =
      case @shipment.mode_of_transport
      when 'ocean' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-01.png'
      when 'air' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-02.png'
      when 'truck' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-03.png'
      when 'rail' then 'https://assets.itsmycargo.com/assets/icons/mots/mot-04.png'
      end

    create_pdf_attachment(@shipment)
    attachments.inline['logo.png']       = URI.open(tenant.theme['logoLarge']).read
    attachments.inline['logo_small.png'] = try(:open, tenant.theme['logoSmall']).try(:read)
    attachments.inline['icon.png'] = URI.open(@mot).read
    mail_options = {
      from: Mail::Address.new("no-reply@#{@user.tenant.subdomain}.#{Settings.emails.domain}")
                         .tap { |a| a.display_name = @user.tenant.name }.format,
      reply_to: @user.tenant.emails.dig('support', 'general'),
      to: mail_target_interceptor(@user, user.email.blank? ? 'itsmycargodev@gmail.com' : user.email),
      bcc: [Settings.emails.booking],
      subject: "Your booking through #{@user.tenant.name}"
    }

    mail(mail_options, &:html)
  end

  private

  def generate_and_upload_bill_of_lading
    bill_of_lading = PdfHandler.new(
      layout: 'pdfs/simple.pdf.html.erb',
      template: 'shipments/pdfs/bill_of_lading.pdf.html.erb',
      margin: { top: 10, bottom: 5, left: 8, right: 8 },
      shipment: @shipment,
      name: 'bill_of_lading'
    )

    bill_of_lading.generate
    bill_of_lading.upload
  end

  def create_pdf_attachment(shipment)
    pdf = ShippingTools.generate_shipment_pdf(shipment: shipment)
    attachments.inline["shipment_#{shipment.imc_reference}.pdf"] = pdf
  end
end
