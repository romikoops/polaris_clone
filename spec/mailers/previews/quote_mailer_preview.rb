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
    organization = Organizations::Organization.find_by(slug: 'lclsaco')
    shipments = Shipment.where(organization: organization)
    quotation = Quotation.where(original_shipment_id: shipments).last
    QuoteMailer.quotation_admin_email(quotation)
  end

  def no_user_quotation_admin_email
    organization = Organizations::Organization.find_by(slug: 'yourdemo')
    shipments = Shipment.where(organization: organization, user_id: nil)
    quotation = Quotation.where(original_shipment_id: shipments.ids, user_id: nil).last

    QuoteMailer.quotation_admin_email(quotation)
  end
end
