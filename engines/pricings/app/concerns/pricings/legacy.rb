# frozen_string_literal: true

module Pricings
  module Legacy
    extend ActiveSupport::Concern

    module ClassMethods
      def create_from_legacy(source)
        create(__legacy_params(source))
      end

      def __legacy_params(model)
        case model
        when ::Pricing
          __legacy_pricing_params(model)
        when ::PricingDetail
          __legacy_pricing_detail_params(model)
        end
      end

      def __legacy_pricing_params(pricing)
        {
          wm_rate: pricing.wm_rate,
          effective_date: pricing.effective_date,
          expiration_date: pricing.expiration_date,
          organization_id: pricing.organization_id,
          cargo_class: pricing.transport_category.cargo_class,
          load_type: pricing.transport_category.load_type,
          user_id: pricing.user_id,
          itinerary_id: pricing.itinerary_id,
          tenant_vehicle_id: pricing.tenant_vehicle_id
        }
      end

      def __legacy_pricing_detail_params(pricing_detail)
        {
          rate: pricing_detail.rate,
          base: 1,
          rate_basis_id: Pricings::RateBasis.find_by(external_code: pricing_detail.rate_basis)&.id,
          min: pricing_detail.min,
          hw_threshold: pricing_detail.hw_threshold,
          hw_rate_basis: pricing_detail.hw_rate_basis,
          charge_category_id: Legacy::ChargeCategory.find_by(
            code: pricing_detail.shipping_type,
            organization_id: pricing_detail.organization_id
          )&.id,
          range: pricing_detail.range,
          currency_name: pricing_detail.currency_name,
          currency_id: pricing_detail.currency_id,
          pricing_id: pricing_detail.pricing_id,
          organization_id: pricing_detail.organization_id
        }
      end
    end

    def update_from_legacy(source)
      update(self.class.__legacy_params(source))
    end
  end
end
