# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class Base
        attr_reader :shipment, :scope

        def initialize(shipment:)
          @shipment = shipment
          @currency = currency_for_user
        end

        def legacy_cargo_from_target(target:)
          return if target.nil? || target.is_a?(Cargo::Cargo)

          target.legacy
        end

        def currency_for_user
          Users::Settings.find_by(user_id: shipment.user_id)&.currency ||
            Organizations::Organization.current.scope&.content&.dig("default_currency")
        end
      end
    end
  end
end
