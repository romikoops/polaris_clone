# frozen_string_literal: true
module Api
  module V1
    class LegacyCargoUnitDecorator < Api::V1::CargoUnitDecorator
      delegate_all

      def legacy_format
        lcl? ? cargo_item_format : container_format
      end

      def cargo_item_format
        {
          width: width,
          height: height,
          length: length,
          cargo_item_type: cargo_item_type,
          cargo_class: "lcl"
        }.merge(common_attributes)
      end

      def container_format
        {
          size_class: cargo_class
        }.merge(common_attributes)
      end

      def aggregate_format
        {
          weight: payload_in_kg,
          volume: volume
        }
      end

      def common_attributes
        {
          id: id,
          quantity: quantity,
          payload_in_kg: payload_in_kg
        }
      end
    end
  end
end
