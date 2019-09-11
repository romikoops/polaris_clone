class QuotationsController < ApplicationController

  def download_pdf
    shipment = Shipment.find(params[:id])
    main_quote = Quotation.find(shipment.quotation_id)
    document = main_quote.documents.where(doc_type: 'quotation').order(:updated_at).first
    response_handler(key: 'quote', url: rails_blob_url(document&.file, disposition: 'attachment'))
  end
end
