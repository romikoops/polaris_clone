# frozen_string_literal: true

class PdfsController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def bill_of_lading
    shipment = current_user.shipments.find(params[:shipment_id])

    if shipment
      render(pdf: "Bill_of_lading_copy_#{shipment.imc_reference}", layout: 'pdfs/simple.pdf', template: 'shipments/pdfs/bill_of_lading.pdf', locals: { shipment: shipment }, show_as_html: params.has_key?('debug'), margin: { top: 5, bottom: 5, left: 5, right: 5 })
    end
  end
end
