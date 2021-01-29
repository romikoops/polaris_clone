# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class Base
        attr_reader :shipment

        def initialize(request:)
          @request = request
          @currency = currency_for_user
        end

        def currency_for_user
          Users::ClientSettings.find_by(user: request.client)&.currency ||
            scope.fetch(:default_currency)
        end

        def scope
          @scope ||= ::OrganizationManager::ScopeService.new(
            target: request.client,
            organization: request.organization
          ).fetch
        end
      end
    end
  end
end
