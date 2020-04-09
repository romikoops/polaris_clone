# frozen_string_literal: true

module Api
  module V1
    class QuotationDecorator < Draper::Decorator
      delegate_all

      decorates_association :tenants_user, with: UserDecorator

      def tenders
        Wheelhouse::TenderDecorator.decorate_collection(object.tenders)
      end

      def shipment
        breakdown = Legacy::ChargeBreakdown.find_by(tender_id: object.tenders.ids)
        Legacy::Shipment.find(breakdown.shipment_id)
      end
    end
  end
end
