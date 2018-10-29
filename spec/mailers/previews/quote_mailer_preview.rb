class QuoteMailerPreview < ActionMailer::Preview
  def quotation_email
    quotation = Quotation.last
    tenant = Tenant.find_by_subdomain('gateway')
    @shipment = tenant.shipments.where(status: 'booking_process_started').last
    @shipments = tenant.shipments.where(quotation_id: quotation.id)
    @email = "demo@itsmycargo.com"
    QuoteMailer.quotation_email(@shipment, @shipments, @email, quotation)
  end
end