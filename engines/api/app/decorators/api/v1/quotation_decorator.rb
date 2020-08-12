# frozen_string_literal: true

module Api
  module V1
    class QuotationDecorator < ApplicationDecorator
      delegate_all

      decorates_association :user, with: UserDecorator
      decorates_association :origin_nexus, with: NexusDecorator
      decorates_association :destination_nexus, with: NexusDecorator

      def tenders
        Wheelhouse::TenderDecorator.decorate_collection(object.tenders)
      end

      def shipment
        Legacy::Shipment.with_deleted.find_by(id: legacy_shipment_id)
      end
    end
  end
end
