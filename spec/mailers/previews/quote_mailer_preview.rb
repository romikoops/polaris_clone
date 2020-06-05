# frozen_string_literal: true

class QuoteMailerPreview < ActionMailer::Preview
  def quotation_email
    ids = Tenant.find_by(subdomain: 'demo').shipments.ids
    quotation = Quotation.where(original_shipment_id: ids).last
    @shipments = Shipment.where(quotation_id: quotation.id)
    @shipment = @shipments.first
    @email = 'demo@itsmycargo.com'
    QuoteMailer.quotation_email(@shipment, @shipments, @email, quotation)
  end

  def quotation_admin_email
    ids = Tenant.find_by(subdomain: 'lclsaco').shipments.ids
    quotation = Quotation.where(original_shipment_id: ids).last
    @shipments = Shipment.where(quotation_id: quotation.id)
    @shipment = @shipments.first
    QuoteMailer.quotation_admin_email(quotation)
  end
end
