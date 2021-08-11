# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Sanitizers
      class Integer < ExcelDataServices::V2::Sanitizers::Base
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
