# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class Zone < ExcelDataServices::V4::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (optional_integer_from_string << decimal_from_string).call(obj) }
          }
        end
      end
    end
  end
end
