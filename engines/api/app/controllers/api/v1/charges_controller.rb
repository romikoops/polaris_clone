# frozen_string_literal: true

require_dependency 'api/api_controller'

module Api
  module V1
    class ChargesController < ApiController
      def show
        decorated_tender = TenderDecorator.decorate(tender)
        render json: QuotationTenderSerializer.new(decorated_tender, params: { scope: current_scope })
      end

      private

      def tender
        charge_breakdown = shipment&.charge_breakdowns&.find_by(trip_id: params[:id])
        Quotations::Tender.find_by(id: charge_breakdown&.tender_id)
      end

      def shipment
        Legacy::Shipment.find(params[:quotation_id])
      end
    end
  end
end
