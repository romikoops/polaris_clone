# frozen_string_literal: true

class Shipments::BookingProcessController < ApplicationController
  skip_before_action :require_non_guest_authentication!,
                     except: %i(update_shipment request_shipment)
  def create_shipment
    resp = ShippingTools.create_shipment(params[:details], current_user)
    response_handler(resp)
  end

  def get_offers
    resp = ShippingTools.get_offers(params, current_user)
    response_handler(resp)
  end

  def choose_offer
    resp = ShippingTools.choose_offer(params, current_user)

    response_handler(resp)
  end

  def send_quotes
    ShippingTools.save_and_send_quotes(shipment, params[:quotes], params[:email])
    response_handler(params)
  end

  def update_shipment
    resp = ShippingTools.update_shipment(params, current_user)
    response_handler(resp)
  end

  def download_quotations
    @document = Document.create!(
      shipment: shipment,
      # quotation: quotation, # TODO: Implement proper quotation tools
      text: "quotation_#{shipment.imc_reference}",
      doc_type: 'quotation',
      user: current_user,
      tenant: current_user.tenant,
      file: {
        io: StringIO.new(
          ShippingTools.save_pdf_quotes(shipment, current_user.tenant, result_params[:quotes].map(&:to_h))
        ),
        filename: "quotation_#{shipment.imc_reference}.pdf",
        content_type: 'application/pdf'
      }
    )

    response_handler(key: 'quotations', url: rails_blob_url(@document.file, disposition: 'attachment'))
  end

  def download_shipment
    shipment_pdf = shipment.documents.where(doc_type: 'shipment_recap').last

    if shipment_pdf.nil?
      @document = Document.create!(
        shipment: shipment,
        text: "shipment_recap_#{shipment.imc_reference}",
        doc_type: 'shipment_recap',
        user: shipment.user,
        tenant: shipment.user.tenant,
        file: {
          io: StringIO.new(ShippingTools.generate_shipment_pdf(shipment: shipment)),
          filename: "shipment_recap_#{shipment.imc_reference}.pdf",
          content_type: 'application/pdf'
        }
      )
    else
      @document = shipment_pdf
      @document.update!(
        shipment: shipment,
        text: "shipment_recap_#{shipment.imc_reference}",
        doc_type: 'shipment_recap',
        user: shipment.user,
        tenant: shipment.user.tenant,
        file: {
          io: StringIO.new(ShippingTools.generate_shipment_pdf(shipment: shipment)),
          filename: "shipment_recap_#{shipment.imc_reference}.pdf",
          content_type: 'application/pdf'
        }
      )
    end

    response_handler(key: 'shipment_recap', url: rails_blob_url(@document.file, disposition: 'attachment'))
  end

  def view_more_schedules
    response = ShippingTools.view_more_schedules(params[:trip_id], params[:delta])

    response_handler(response)
  end

  def request_shipment
    resp = ShippingTools.request_shipment(params, current_user)
    ShippingTools.tenant_notification_email(resp.user, resp)
    ShippingTools.shipper_notification_email(resp.user, resp)
    response_handler(shipment: resp)
  end

  def shipment
    @shipment ||= Shipment.find(params[:shipment_id])
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
end
