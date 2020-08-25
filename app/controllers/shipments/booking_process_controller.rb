# frozen_string_literal: true

class Shipments::BookingProcessController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: [:create_shipment, :get_offers]

  def create_shipment
    resp = ShippingTools.new.create_shipment(params[:details], organization_user)
    response_handler(resp)
  end

  def get_offers
    resp = ShippingTools.new.get_offers(params, organization_user)
    Skylight.instrument title: 'Serialize Results' do
      resp = resp.to_json if params[:async].blank?
    end
    response_handler(resp)
  end

  def choose_offer
    resp = ShippingTools.new.choose_offer(params, organization_user)

    response_handler(resp)
  end

  def send_quotes
    ShippingTools.new.save_and_send_quotes(shipment,
                                       save_and_send_params[:quotes].map(&:to_h),
                                       organization_user.email)
    response_handler(params)
  end

  def update_shipment
    resp = ShippingTools.new.update_shipment(params, organization_user)
    response_handler(resp)
  end

  def refresh_quotes
    resp = shipment.charge_breakdowns.map do |charge_breakdown|
      {
        trip_id: charge_breakdown.trip_id,
        quote: charge_breakdown.to_nested_hash(Pdf::HiddenValueService.new(user: organization_user).hide_total_args)
      }
    end

    response_handler(resp)
  end

  def download_quotations
    document = ShippingTools.new.save_pdf_quotes(shipment, current_organization, result_params[:quotes].map(&:to_h))
    response_handler(key: 'quotations', url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: 'attachment'))
  end

  def download_shipment
    document = Pdf::Service.new(organization: current_organization, user: shipment.user).shipment_pdf(shipment: shipment)

    response_handler(
      key: 'shipment_recap',
      url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: 'attachment')
    )
  end

  def view_more_schedules
    response = ShippingTools.new.view_more_schedules(params[:trip_id], params[:delta])

    response_handler(response)
  end

  def request_shipment
    resp = ShippingTools.new.request_shipment(params, organization_user)
    ShippingTools.new.tenant_notification_email(resp.user, resp)
    ShippingTools.new.shipper_notification_email(resp.user, resp)
    response_handler(shipment: resp)
  end

  def shipment
    @shipment ||= Legacy::Shipment.find_by(id: params[:shipment_id])
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
