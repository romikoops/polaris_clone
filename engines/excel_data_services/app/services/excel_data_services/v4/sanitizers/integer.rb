# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class Integer < ExcelDataServices::V4::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::Float => ->(obj) { integer.call(obj) },
            ::Integer => ->(obj) { integer.call(obj) }
          }
        end
      end
    end
  end
end
