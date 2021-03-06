# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Sanitizers
      class Base
        DIRECT_TRANSSHIPMENT_IDENTIFIERS = %w[direct direkt].freeze

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
          proc(&:to_s)
        end

        def strip
          proc(&:strip)
        end

        def upcase
          proc(&:upcase)
        end

        def downcase
          proc(&:downcase)
        end

        def decimal
          proc(&:to_d)
        end

        def date
          proc { |value| ::DateTime.parse(value).to_date }
        end

        def integer
          proc(&:to_i)
        end

        def nan_as_nil
          proc { |value| value.nan? ? nil : value }
        end

        def enforce_string_from_numeric
          proc { |value| value ? value.to_s : nil }
        end

        def decimal_from_string
          proc { |value| value[/\A-?(?:\d+(?:\.\d*)?|\.\d+)/] }
        end

        def spaces
          proc { |value| value.delete(" ") }
        end

        def direct_as_nil
          proc { |value| DIRECT_TRANSSHIPMENT_IDENTIFIERS.include?(value.downcase) ? nil : value }
        end

        def optional_integer_from_string
          proc do |value|
            decimal = value.to_i
            if decimal.zero?
              nil
            else
              decimal.to_s
            end
          end
        end

        def identifier
          proc { |value| value.casecmp("zipcode").zero? ? "postal_code" : value.downcase }
        end
      end
    end
  end
end
