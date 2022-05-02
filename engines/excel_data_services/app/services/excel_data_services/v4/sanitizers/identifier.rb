# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class Identifier < ExcelDataServices::V4::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { identifier.call(obj) }
          }
        end
      end
    end
  end
end
