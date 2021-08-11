# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Sanitizers
      class Boolean < ExcelDataServices::V2::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::Float => ->(obj) { decimal.call(obj).positive? },
            ::Integer => ->(obj) { integer.call(obj).positive? },
            ::String => ->(obj) { strip.call(obj).match?(/t|T/) },
            ::NilClass => ->(_obj) { false },
            ::TrueClass => ->(_obj) { true },
            ::FalseClass => ->(_obj) { false }
          }
        end
      end
    end
  end
end
