# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class Decimal < ExcelDataServices::V4::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::Float => ->(obj) { decimal.call(obj) },
            ::Integer => ->(obj) { decimal.call(obj) },
            ::String => ->(obj) { (decimal << decimal_from_string).call(obj) }
          }
        end
      end
    end
  end
end
