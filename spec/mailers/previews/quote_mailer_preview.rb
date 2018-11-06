class QuoteMailerPreview < ActionMailer::Preview
  def quotation_email
    quotation = Quotation.last
    @shipments = Shipment.where(quotation_id: quotation.id)
    @shipment = @shipments.first
    tenant = @shipment.tenant
    @email = "demo@itsmycargo.com"
    QuoteMailer.quotation_email(@shipment, @shipments, @email, quotation)
  end
end