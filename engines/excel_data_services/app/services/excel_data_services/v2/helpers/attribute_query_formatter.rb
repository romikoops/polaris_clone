# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Helpers
      class AttributeQueryFormatter
        def initialize(arguments:)
          @arguments = arguments
        end

        def perform
          arguments.keys.map { |key| sanitize_for_null(key: key) }.join(" AND ")
        end

        private

        attr_reader :arguments

        def sanitize_for_null(key:)
          if arguments[key].nil?
            "#{key} IS NULL"
          else
            "#{key} = :#{key}"
          end
        end
      end
    end
  end
end
