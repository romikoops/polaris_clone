# frozen_string_literal: true

class QuoteMailerPreview < ActionMailer::Preview
  def quotation_email
    organization = Organizations::Organization.find_by(slug: "lclsaco")
    user = Users::Client.find_by(organization_id: organization.id, email: "agent@itsmycargo.com")
    quotation = Legacy::Quotation.where(user: user).last
    @shipments = Legacy::Shipment.where(quotation_id: quotation.id)
    @shipment = Legacy::Shipment.find(quotation.original_shipment_id)
    quotations_quotation = Quotations::Quotation.find_by(legacy_shipment_id: @shipment.id)
    @email = "demo@itsmycargo.com"
    tender_ids = quotations_quotation.tenders.ids

    QuoteMailer.new_quotation_email(quotation: quotations_quotation,
                                    tender_ids: tender_ids, shipment: @shipment, email: @email)
  end

  def quotation_admin_email
    organization = Organizations::Organization.find_by(slug: "lclsaco")
    shipments = Shipment.where(organization: organization)
    quotation = Quotation.where(original_shipment_id: shipments).last
    quotations_quotation = Quotations::Quotation.find_by(legacy_shipment_id: quotation.original_shipment_id)
    QuoteMailer.new_quotation_admin_email(quotation: quotations_quotation, shipment: quotation.original_shipment)
  end

  def no_user_quotation_admin_email
    organization = Organizations::Organization.find_by(slug: "yourdemo")
    shipments = Shipment.where(organization: organization, user_id: nil)
    quotation = Quotation.where(original_shipment_id: shipments.ids, user_id: nil).last

    QuoteMailer.new_quotation_admin_email(quotation)
  end
end
