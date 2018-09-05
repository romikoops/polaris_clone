class QuoteMailerPreview < ActionMailer::Preview
  def quotation_email
    quotation = Quotation.last
    @shipment = Shipment.where(status: 'booking_process_started').last
    @shipments = Shipment.where(quotation_id: quotation.id)
    @email = "demo@itsmycargo.com"
    QuoteMailer.quotation_email(@shipment, @shipments, @email)
  end
end