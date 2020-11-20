# frozen_string_literal: true

require_dependency "api/application_controller"

module Api
  module V1
    class TendersController < ApiController
      def update
        updated_tender = tender_updater.perform
        decorated_tender = TenderDecorator.decorate(updated_tender, context: {scope: current_scope})
        render json: QuotationTenderSerializer.new(decorated_tender, params: {scope: current_scope})
      end

      private

      def tender
        Quotations::Tender.find(update_params[:id])
      end

      def tender_updater
        Quotations::TenderUpdater.new(tender: tender,
                                      line_item_id: update_params[:line_item_id],
                                      charge_category_id: update_params[:charge_category_id],
                                      value: update_params[:value],
                                      section: update_params[:section])
      end

      def update_params
        params.permit(:id, :line_item_id, :charge_category_id, :value, :section)
      end
    end
  end
end
