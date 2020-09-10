# frozen_string_literal: true

module OfferCalculator
  class QuotedShipmentsJob < OfferCalculator::ApplicationJob
    queue_as :critical

    def perform(shipment_id:, send_email: nil, mailer: nil)
      OfferCalculator::QuotedShipmentsService.new(
        shipment_id: shipment_id, send_email: send_email, mailer: mailer
      ).perform
    end
  end
end
