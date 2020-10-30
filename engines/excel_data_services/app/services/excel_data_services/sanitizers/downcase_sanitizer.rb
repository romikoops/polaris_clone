# frozen_string_literal: true

module ExcelDataServices
  module Sanitizers
    class DowncaseSanitizer < ExcelDataServices::Sanitizers::StringSanitizer
      def valid_types_with_sanitizers
        {
          String => ->(obj) { (string << downcase).call(obj) }
        }
      end
    end
  end
end
