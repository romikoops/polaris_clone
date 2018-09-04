# frozen_string_literal: true

class Shipments::BookingProcessController < ApplicationController
  skip_before_action :require_non_guest_authentication!,
    except: %i[update_shipment request_shipment]
  def create_shipment
    resp = ShippingTools.create_shipment(params[:details], current_user)
    response_handler(resp)
  end

  def get_offers
    resp = ShippingTools.get_offers(params, current_user)
    response_handler(resp)
  end

  def choose_offer
    shipment = Shipment.find(params[:shipment_id])
    resp = ShippingTools.choose_offer(params, current_user)
    response_handler(resp)
  end

  def choose_quotes
    shipment = Shipment.find(params[:shipment_id])
    ShippingTools.save_and_send_quotes(shipment, params[:quotes], params[:email])
    # response_handler(resp)
  end

  def update_shipment
    resp = ShippingTools.update_shipment(params, current_user)
    response_handler(resp)
  end

  def download_quotations
    shipment = Shipment.find(params[:shipment_id])
    quotation = PdfHandler.new(
      layout:   "pdfs/simple.pdf.html.erb",
      template: "shipments/pdfs/quotations.pdf.erb",
      margin:   { top: 10, bottom: 5, left: 8, right: 8 },
      shipment: shipment,
      quotes:   params[:options].fetch(:quote),
      name:     "quotation"
    )
    quotation.generate
    quotation.upload
  end

  def request_shipment
    resp = ShippingTools.request_shipment(params, current_user)
    ShippingTools.tenant_notification_email(resp.user, resp)
    ShippingTools.shipper_notification_email(resp.user, resp)
    response_handler(shipment: resp)
  end
end
