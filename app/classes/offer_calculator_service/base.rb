# frozen_string_literal: true

module OfferCalculatorService
  class Base
    def initialize(shipment)
      @shipment = shipment
      @scope    = ::Tenants::ScopeService.new(user: @shipment.user).fetch
    end
  end
end
