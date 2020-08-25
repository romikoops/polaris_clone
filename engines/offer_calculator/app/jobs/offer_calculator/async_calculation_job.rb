# frozen_string_literal: true

module OfferCalculator
  class AsyncCalculationJob < ApplicationJob
    queue_as :critical

    def perform(shipment_id:, quotation_id:, user_id:, wheelhouse:, mailer: nil)
      @shipment = Legacy::Shipment.find(shipment_id)
      @quotation = Quotations::Quotation.find(quotation_id)
      @user = Organizations::User.find_by(id: user_id)

      Organizations.current_id = @shipment.organization_id

      OfferCalculator::Results.new(
        shipment: @shipment,
        quotation: @quotation,
        user: @user,
        wheelhouse: wheelhouse,
        async: true,
        mailer: mailer
      ).perform
    end
  end
end
