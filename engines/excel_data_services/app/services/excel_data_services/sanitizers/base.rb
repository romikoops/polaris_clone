# frozen_string_literal: true

module ExcelDataServices
  module Sanitizers
    class Base
      def initialize(value:)
        @value = value
      end

      def self.sanitize(value:)
        new(value: value).perform
      end

      def perform
        valid_types_with_sanitizers.each do |type, lambd|
          next unless value.is_a?(type)

          return lambd.call(value)
        end

        value
      end

      private

      attr_reader :value

      def string
        proc { |value| value.strip }
      end

      def upcase
        proc { |value| value.upcase }
      end

      def downcase
        proc { |value| value.downcase }
      end

      def decimal
        proc { |value| value.to_d }
      end

      def integer
        proc { |value| value.to_i }
      end

      def nan_as_nil
        proc { |value| value.nan? ? nil : value }
      end

      def enforce_string_from_numeric
        proc { |value| value ? value.to_s : nil }
      end
    end
  end
end
