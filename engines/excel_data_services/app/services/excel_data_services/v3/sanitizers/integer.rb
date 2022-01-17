# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Sanitizers
      class Integer < ExcelDataServices::V3::Sanitizers::Base
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
