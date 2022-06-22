# frozen_string_literal: true

module Notifications
  class Events
    EVENT_JOBS_LOOKUP = {
      Users::UserCreated => [Notifications::AdminUserCreatedJob, Notifications::UserCreatedJob],
      Journey::OfferCreated => [Notifications::OfferCreated::AdminNotifierJob],
      Journey::ShipmentRequestCreated => [Notifications::ShipmentRequestCreatedJob],
      Journey::RequestForQuotationEvent => [Notifications::RequestForQuotationJob]
    }.freeze
  end
end
