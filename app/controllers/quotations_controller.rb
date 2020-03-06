# frozen_string_literal: true

class QuotationsController < ApplicationController
  def download_pdf
    shipment = Shipment.find(params[:id])
    quotation = Quotation.find(shipment.quotation_id)
    document = Pdf::Service.new(user: shipment.user, tenant: shipment.tenant)
                         .quotation_pdf(quotation: quotation)
    response = Rails.application.routes.url_helpers.rails_blob_url(document&.file, disposition: 'attachment') if document&.file
    response_handler(key: 'quote', url: response)
  end
end
