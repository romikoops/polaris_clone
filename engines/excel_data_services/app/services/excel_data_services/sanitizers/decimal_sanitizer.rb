# frozen_string_literal: true

module ExcelDataServices
  module Sanitizers
    class DecimalSanitizer < ExcelDataServices::Sanitizers::Base
      def valid_types_with_sanitizers
        {
          Float => ->(obj) { decimal.call(obj) },
          Integer => ->(obj) { decimal.call(obj) },
          String => ->(obj) { decimal.call(obj[/\A-?(?:\d+(?:\.\d*)?|\.\d+)/]) }
        }
      end
    end
  end
end
