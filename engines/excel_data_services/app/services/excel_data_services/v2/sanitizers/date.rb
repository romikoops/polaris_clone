# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Sanitizers
      class Date < ExcelDataServices::V2::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::Float => ->(obj) { date.call(obj) },
            ::Integer => ->(obj) { date.call(obj) },
            ::String => ->(obj) { date.call(obj) }
          }
        end
      end
    end
  end
end
