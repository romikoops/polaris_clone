# frozen_string_literal: true

module ExcelDataServices
  module Sanitizers
    class UpcaseSanitizer < ExcelDataServices::Sanitizers::Base
      def valid_types_with_sanitizers
        {
          String => ->(obj) { (string << upcase).call(obj) }
        }
      end
    end
  end
end
