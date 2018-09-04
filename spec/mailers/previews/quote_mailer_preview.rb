class QuoteMailerPreview < ActionMailer::Preview
  def quotation_email
    @quotation = Quotation.last
    @shipment = Shipment.where(status: 'quoted').last
    @shipments = Shipment.where(quotation_id: @quotation.id)
    @quotes = @shipments.map { |shipment| shipment.selected_offer }
    @email = "demo@itsmycargo.com"
    QuoteMailer.quotation_email(@shipment, @shipments, @quotes, @email)
  end
end