# frozen_string_literal: true

class QuoteMailerPreview < ActionMailer::Preview
  def quotation_email
    # quotation = Quotation.last
    quotation = Tenant.fivestar.shipments.where.not(quotation_id: nil).last.quotation
    @shipments = Shipment.where(quotation_id: quotation.id)
    @shipments = Shipment.where(quotation_id: quotation.id)
    @shipment = @shipments.first
    @email = 'demo@itsmycargo.com'
    QuoteMailer.quotation_email(@shipment, @shipments, @email, quotation)
  end
end
