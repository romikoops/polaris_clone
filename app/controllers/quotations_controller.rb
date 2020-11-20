# frozen_string_literal: true

class QuotationsController < ApplicationController
  include Wheelhouse::ErrorHandler

  def show
    quotation = Quotations::Quotation.find(params[:id])
    raise quotation.error_class.constantize if quotation.error_class

    response_handler(QuotationDecorator.new(quotation, context: {scope: current_scope}).legacy_json)
  rescue OfferCalculator::Errors::Failure => e
    handle_error(error: e)
  end

  def download_pdf
    shipment = Shipment.find(params[:id])
    tender = Quotations::Tender.find(shipment.tender_id)
    document = Pdf::Quotation::Client.new(quotation: tender.quotation, tender_ids: [tender.id]).file
    response = if document&.file
      Rails.application.routes.url_helpers.rails_blob_url(document&.file, disposition: "attachment")
    end
    response_handler(key: "quote", url: response)
  end
end
