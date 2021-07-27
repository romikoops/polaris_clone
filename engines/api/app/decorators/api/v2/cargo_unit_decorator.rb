# frozen_string_literal: true

module Api
  module V2
    class CargoUnitDecorator < ApplicationDecorator
      delegate_all

      def weight
        weight_value && weight_value.to_f
      end

      def width
        width_value && (width_value * 100.0).to_f
      end

      def height
        height_value && (height_value * 100.0).to_f
      end

      def length
        length_value && (length_value * 100.0).to_f
      end

      def volume
        volume_value && volume_value.to_f
      end
    end
  end
end
