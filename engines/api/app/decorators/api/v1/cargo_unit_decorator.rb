module Api
  module V1
    class CargoUnitDecorator < ApplicationDecorator
      delegate_all

      def cargo_item_type
        {
          description: colli_type.humanize
        }
      end

      def payload_in_kg
        weight_value
      end

      def chargeable_weight
        [wm_ratio * weight_value, weight_value].max
      end

      def dangerous_goods
        Journey::CommodityInfo.where(cargo_unit: object).exists?(imo_class: "0")
      end

      def hs_codes
        Journey::CommodityInfo.where(cargo_unit: object).where.not(hs_code: "").pluck(:hs_code)
      end

      def weight_class
      end

      def tare_weight
      end

      def gross_weight
      end

      def customs_text
        ""
      end

      def unit_price
        {

        }
      end

      def contents
        ""
      end

      def width
        width_value * 100.0
      end

      def height
        height_value * 100.0
      end

      def length
        length_value * 100.0
      end

      def wm_ratio
        context.dig(:wm_ratio) || 0
      end

      def cargo_item_type_id
        Legacy::CargoItemType.joins(:tenant_cargo_item_types).where(tenant_cargo_item_types: {organization_id: query.organization_id})
          .where("category ILIKE ?", "%#{colli_type}%").first&.id
      end
    end
  end
end
