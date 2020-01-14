# frozen_string_literal: true

class Shipments::BookingProcessController < ApplicationController
  skip_before_action :require_non_guest_authentication!,
                     except: %i(update_shipment request_shipment)
  def create_shipment
    resp = ShippingTools.create_shipment(params[:details], current_user, @sandbox)
    response_handler(resp)
  end

  def get_offers
    resp = ShippingTools.get_offers(params, current_user, @sandbox)
    response_handler(resp)
  end

  def choose_offer
    resp = ShippingTools.choose_offer(params, current_user, @sandbox)

    response_handler(resp)
  end

  def send_quotes
    ShippingTools.save_and_send_quotes(shipment, save_and_send_params[:quotes].map(&:to_h), params[:email], @sandbox)
    response_handler(params)
  end

  def update_shipment
    resp = ShippingTools.update_shipment(params, current_user, @sandbox)
    response_handler(resp)
  end

  def download_quotations
    document = ShippingTools.save_pdf_quotes(shipment, current_user.tenant, result_params[:quotes].map(&:to_h), @sandbox)
    response_handler(key: 'quotations', url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: 'attachment'))
  end

  def download_shipment
    document = PdfService.new(tenant: shipment.tenant, user: shipment.user).shipment_pdf(shipment: shipment)

    response_handler(
      key: 'shipment_recap',
      url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: 'attachment')
    )
  end

  def view_more_schedules
    response = ShippingTools.view_more_schedules(params[:trip_id], params[:delta], @sandbox)

    response_handler(response)
  end

  def request_shipment
    resp = ShippingTools.request_shipment(params, current_user, @sandbox)
    ShippingTools.tenant_notification_email(resp.user, resp, @sandbox)
    ShippingTools.shipper_notification_email(resp.user, resp, @sandbox)
    response_handler(shipment: resp)
  end

  def shipment
    @shipment ||= ::Shipment.find_by(id: params[:shipment_id], sandbox: @sandbox)
  end

  private

  def result_params
    params.require(:options).permit(quotes:
      [
        quote: {},
        schedules: [:id, :mode_of_transport, :total_price, :eta, :etd, :closing_date, :vehicle_name,
                    :carrier_name, :trip_id, origin_hub: {}, destination_hub: {}],
        meta: {}
      ])
  end

  def save_and_send_params
    params.permit(quotes:
      [
        quote: {},
        schedules: [:id, :mode_of_transport, :total_price, :eta, :etd, :closing_date, :vehicle_name,
                    :carrier_name, :trip_id, origin_hub: {}, destination_hub: {}],
        meta: {}
      ])
  end
end
