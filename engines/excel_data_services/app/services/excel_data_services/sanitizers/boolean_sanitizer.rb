# frozen_string_literal: true

module ExcelDataServices
  module Sanitizers
    class BooleanSanitizer < ExcelDataServices::Sanitizers::Base
      def valid_types_with_sanitizers
        {
          Float => ->(obj) { decimal.call(obj).positive? },
          Integer => ->(obj) { integer.call(obj).positive? },
          String => ->(obj) { string.call(obj).match?(/t|T/) },
          NilClass => ->(_obj) { false },
          TrueClass => ->(_obj) { true },
          FalseClass => ->(_obj) { false }
        }
      end
    end
  end
end
