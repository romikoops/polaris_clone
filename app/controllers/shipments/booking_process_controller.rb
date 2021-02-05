# frozen_string_literal: true

class Shipments::BookingProcessController < ApplicationController
  skip_before_action :doorkeeper_authorize!, only: [:create_shipment, :get_offers]
  before_action :confirm_request_eligibility, only: [:get_offers]
  before_action :attach_user_to_shipment, only: [:get_offers, :choose_offer]

  include Wheelhouse::ErrorHandler

  def create_shipment
    response_handler(
      ShippingTools.new.create_shipment(params[:details], organization_user)
    )
  end

  def get_offers
    offer_query = OfferCalculator::Calculator.new(
      source: source,
      client: organization_user,
      creator: organization_user,
      params: offer_calculator_params
    ).perform
    resp = Api::V1::LegacyQueryDecorator.new(
      offer_query,
      context: {scope: current_scope}
    ).legacy_json
    resp = resp.to_json if params[:async].blank?
    response_handler(resp)
  rescue OfferCalculator::Errors::Failure => error
    handle_error(error: error)
  rescue ArgumentError
    raise ApplicationError::InternalError
  end

  def choose_offer
    resp = ShippingTools.new.choose_offer(params, organization_user)

    response_handler(resp)
  end

  def send_quotes
    Notifications::ClientMailer.with(
      organization: current_organization,
      offer: offer_from_results,
      user: current_user
    ).offer_email.deliver_now
    response_handler(params)
  end

  def update_shipment
    resp = ShippingTools.new.update_shipment(params, organization_user)
    response_handler(resp)
  end

  def refresh_quotes
    resp = shipment.charge_breakdowns.map { |charge_breakdown|
      {
        trip_id: charge_breakdown.trip_id,
        quote: charge_breakdown.to_nested_hash(Pdf::HiddenValueService.new(user: organization_user).hide_total_args)
      }
    }

    response_handler(resp)
  end

  def download_quotations
    response_handler(
      key: "quotations",
      url: Rails.application.routes.url_helpers.rails_blob_url(offer_from_results.file, disposition: "attachment")
    )
  end

  def download_shipment
    document = Pdf::Shipment::Recap.new(quotation: quotations_quotation, shipment: shipment).file

    response_handler(
      key: "shipment_recap",
      url: Rails.application.routes.url_helpers.rails_blob_url(document.file, disposition: "attachment")
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

  def quotations_quotation
    @quotations_quotation ||= shipment_tender.quotation
  end

  def shipment_tender
    @shipment_tender ||= Quotations::Tender.find(shipment.tender_id)
  end

  def result_params
    params.require(:options).permit(
      quotes:
      [
        quote: {},
        schedules: [:id, :mode_of_transport, :total_price, :eta, :etd, :closing_date, :vehicle_name,
          :carrier_name, :trip_id, origin_hub: {}, destination_hub: {}],
        meta: {}
      ]
    )
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

  def confirm_request_eligibility
    guest_ineligible = current_scope.values_at(:closed_shop, :closed_after_map, :closed_quotation_tool).any?(&:present?)
    raise ApplicationError::NotLoggedIn if guest_ineligible && current_user.blank?
  end

  def attach_user_to_shipment
    shipment.update(user: organization_user)
  end

  def offer_calculator_params
    params.permit(shipment: {})[:shipment].to_h.merge(async: params[:async], load_type: load_type)
  end

  def load_type
    params.dig(:shipment, :containers_attributes).present? ? "container" : "cargo_item"
  end

  def offer_from_results
    Wheelhouse::OfferBuilder.offer(results: Journey::Result.where(id: offer_result_ids))
  end

  def offer_result_ids
    dynamic_params = params[:options].present? ? result_params : save_and_send_params
    dynamic_params[:quotes].map { |result| result.dig("meta", "tender_id") }
  end

  def source
    current_user.present? ? doorkeeper_application : Doorkeeper::Application.find_by(name: "dipper")
  end
end
