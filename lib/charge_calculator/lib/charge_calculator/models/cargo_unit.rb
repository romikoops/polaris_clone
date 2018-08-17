# frozen_string_literal: true

module ChargeCalculator
  module Models
    class CargoUnit < Base
      def volume
        @volume ||= data.fetch(:volume) { volume_from_dimensions }
      end

      private

      def volume_from_dimensions
        return nil if self[:dimensions].nil?

        self[:dimensions].values.reduce(1) { |acc, v| acc * BigDecimal(v) } / 1_000_000
      end
    end
  end
end
