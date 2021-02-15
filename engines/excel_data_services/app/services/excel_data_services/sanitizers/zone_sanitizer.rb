# frozen_string_literal: true

module ExcelDataServices
  module Sanitizers
    class ZoneSanitizer < ExcelDataServices::Sanitizers::Base
      def valid_types_with_sanitizers
        {
          String => ->(obj) { string.call(obj.gsub(".0", "")) }
        }
      end
    end
  end
end
