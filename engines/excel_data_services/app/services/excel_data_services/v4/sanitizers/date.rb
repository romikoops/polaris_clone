# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class Date < ExcelDataServices::V4::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { date.call(obj) }
          }
        end
      end
    end
  end
end
