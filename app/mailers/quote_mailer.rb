# frozen_string_literal: true

class QuoteMailer < ApplicationMailer
  default from: 'ItsMyCargo Bookings <bookings@itsmycargo.com>'
  layout 'mailer'
  add_template_helper(ApplicationHelper)

  def quotation_email(shipment, shipments, email, quotation, sandbox = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @shipments = shipments
    @shipment = shipment
    @quotation = quotation
    @quotes = quotes_with_trip_id(@quotation, @shipments)
    @user = @shipment.user
    @theme = @user.tenant.theme
    @email = email[/[^@]+/]
    @content = Content.get_component('QuotePdf', @user.tenant.id)
    @scope = ::Tenants::ScopeService.new(target: @user, sandbox: sandbox).fetch
    @mot_icon = URI.open(
      "https://assets.itsmycargo.com/assets/icons/mail/mail_#{@shipments.first.mode_of_transport}.png"
    ).read
    quotation = generate_and_upload_quotation(@quotes)
    @document = Document.create!(
      shipment: shipment,
      text: "quotation_#{@shipments.pluck(:imc_reference).join(',')}",
      doc_type: 'quotation',
      user: @user,
      tenant: @user.tenant,
      sandbox: sandbox,
      file: {
        io: StringIO.new(quotation),
        filename: "quotation_#{@shipments.pluck(:imc_reference).join(',')}.pdf",
        content_type: 'application/pdf'
      }
    )
    pdf_name = "quotation_#{@shipments.pluck(:imc_reference).join(',')}.pdf"
    attachments.inline['logo.png'] = URI.try(:open, @theme['logoLarge']).try(:read)
    attachments.inline['icon.png'] = @mot_icon
    attachments[pdf_name] = quotation

    mail(
      from: Mail::Address.new("no-reply@#{::Tenants::Tenant.find_by(legacy_id: @user.tenant_id).default_domain}")
                         .tap { |a| a.display_name = @user.tenant.name }.format,
      reply_to: @user.tenant.emails.dig('support', 'general'),
      to: mail_target_interceptor(@user, email),
      subject: "#{sandbox ? '[SANDBOX] - ' : ''} Quotation for #{@shipments.pluck(:imc_reference).join(',')}"
    ) do |format|
      format.html
      format.mjml
    end
  end

  def quotes_with_trip_id(quotation, shipments)
    if quotation
      shipments.map { |s| s.selected_offer.merge(trip_id: s.trip_id).deep_stringify_keys }
    else
      shipments.first.charge_breakdowns.map { |cb| cb.to_nested_hash.merge(trip_id: cb.trip_id).deep_stringify_keys }
    end
  end

  def quotation_admin_email(quotation, shipment = nil, sandbox = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @shipments = quotation ? quotation.shipments : [shipment]
    @shipment = quotation ? Shipment.find(quotation.original_shipment_id) : shipment
    @quotation = quotation
    @quotes = quotes_with_trip_id(@quotation, @shipments)
    @user = @shipment.user
    @theme = @user.tenant.theme
    @content = Content.get_component('QuotePdf', @user.tenant.id)
    @scope = ::Tenants::ScopeService.new(target: @user).fetch
    quotation = generate_and_upload_quotation(@quotes, sandbox)
    @document = Document.create!(
      shipment: @shipment,
      text: "quotation_#{@shipments.pluck(:imc_reference).join(',')}",
      doc_type: 'quotation',
      user: @user,
      tenant: @user.tenant,
      sandbox: sandbox,
      file: {
        io: StringIO.new(quotation),
        filename: "quotation_#{@shipments.pluck(:imc_reference).join(',')}.pdf",
        content_type: 'application/pdf'
      }
    )
    pdf_name = "quotation_#{@shipments.pluck(:imc_reference).join(',')}.pdf"
    attachments.inline['logo.png'] = URI.try(:open, @theme['logoLarge']).try(:read)
    attachments[pdf_name] = quotation
    @hub_names = {
      origin: Trip.find(@quotes.first['trip_id']).itinerary.first_stop.hub.name,
      destination: Trip.find(@quotes.first['trip_id']).itinerary.last_stop.hub.name
    }

    mail(
      from: Mail::Address.new("no-reply@#{::Tenants::Tenant.find_by(legacy_id: @user.tenant_id).default_domain}")
                         .tap { |a| a.display_name = 'ItsMyCargo Quotation Tool' }.format,
      reply_to: Settings.emails.support,
      to: mail_target_interceptor(@user, @user.tenant.email_for(:sales, @shipment.mode_of_transport)),
      subject: "#{sandbox ? '[SANDBOX] - ' : ''} Quotation for #{@shipments.pluck(:imc_reference).join(',')}"
    ) do |format|
      format.html
      format.mjml
    end
  end

  private

  def generate_and_upload_quotation(quotes, sandbox = nil)
    quotation = PdfHandler.new(
      layout: 'pdfs/simple.pdf.html.erb',
      template: 'shipments/pdfs/quotations.pdf.erb',
      margin: { top: 15, bottom: 5, left: 8, right: 8 },
      shipment: @shipment,
      shipments: @shipments,
      quotation: @quotation,
      quotes: quotes,
      color: @user.tenant.theme['colors']['primary'],
      name: 'quotation',
      remarks: Remark.where(tenant_id: @user.tenant_id, sandbox: sandbox).order(order: :asc),
      scope: ::Tenants::ScopeService.new(target: @user, sandbox: sandbox).fetch
    )
    quotation.generate
  end
end
