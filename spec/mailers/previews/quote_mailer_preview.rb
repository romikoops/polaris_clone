# frozen_string_literal: true

class QuoteMailerPreview < ActionMailer::Preview
  def quotation_email
    ids = Tenant.gateway.shipments.ids
    quotation = Quotation.where(original_shipment_id: ids).last
    @shipments = Shipment.where(quotation_id: quotation.id)
    @shipment = @shipments.first
    @email = 'demo@itsmycargo.com'
    QuoteMailer.quotation_email(@shipment, @shipments, @email, quotation)
  end

  def quotation_admin_email
    ids = Tenant.gateway.shipments.ids
    quotation = Quotation.where(original_shipment_id: ids).last
    @shipments = Shipment.where(quotation_id: quotation.id)
    @shipment = @shipments.first
    QuoteMailer.quotation_admin_email(@shipment, @shipments, quotation)
  end
end
