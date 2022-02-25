# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Sanitizers
      class Identifier < ExcelDataServices::V3::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { identifier.call(obj) }
          }
        end
      end
    end
  end
end
