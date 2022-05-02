# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class Text < ExcelDataServices::V4::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (strip << string).call(obj) },
            ::Float => ->(obj) { (enforce_string_from_numeric << nan_as_nil).call(obj) },
            ::Integer => ->(obj) { enforce_string_from_numeric.call(obj) }
          }
        end
      end
    end
  end
end
