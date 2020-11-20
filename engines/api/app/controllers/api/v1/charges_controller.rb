# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class ChargesController < ApiController
      def show
        decorated_tender = TenderDecorator.decorate(tender, context: {scope: current_scope})
        render json: QuotationTenderSerializer.new(decorated_tender, params: {scope: current_scope})
      end

      private

      def tender
        Quotations::Tender.find(tender_params[:id])
      end

      def tender_params
        params.permit(:id)
      end
    end
  end
end
