# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Sanitizers
      class Date < ExcelDataServices::V3::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { date.call(obj) }
          }
        end
      end
    end
  end
end
