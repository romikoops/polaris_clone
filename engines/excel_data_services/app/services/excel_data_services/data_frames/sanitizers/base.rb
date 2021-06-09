# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      class Base
        def self.sanitize(value:, attribute:)
          new(value: value, attribute: attribute).perform
        end

        def initialize(value:, attribute:)
          @value = value
          @attribute = attribute
        end

        def perform
          return default_values[attribute] if value.blank? || sanitizer_klass.blank?

          sanitizer_klass.sanitize(value: value)
        end

        private

        attr_reader :value, :attribute

        def sanitizer_klass
          "ExcelDataServices::Sanitizers::#{merged_sanitizer_lookup[attribute].camelize}Sanitizer".safe_constantize
        end

        def default_values
          {}
        end

        def merged_sanitizer_lookup
          {
            "group_id" => "string",
            "organization_id" => "string",
            "hub_id" => "integer"
          }.merge(sanitizer_lookup)
        end

        def sanitizer_lookup
          {}
        end
      end
    end
  end
end
