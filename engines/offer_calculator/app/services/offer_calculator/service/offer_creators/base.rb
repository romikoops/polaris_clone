# frozen_string_literal: true

module OfferCalculator
  module Service
    module OfferCreators
      class Base
        attr_reader :shipment

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
            scope.fetch(:default_currency)
        end

        def scope
          @scope ||= ::OrganizationManager::ScopeService.new(
            target: shipment.user,
            organization: shipment.organization
          ).fetch
        end

        def update_shipment_meta(key:, value:)
          shipment.meta[key] ||= {}
          shipment.meta[key][tender.id] = value
          shipment.save!
        end

        def pricing_ids
          return shipment.meta.dig("pricing_ids", tender.id) if shipment.meta.dig("pricing_ids", tender.id).present?
          return [] if offer.blank?

          pricing_id_array = offer.pricing_ids(section_key: "cargo")
          update_shipment_meta(key: "pricing_ids", value: pricing_id_array)
          pricing_id_array
        end
      end
    end
  end
end
