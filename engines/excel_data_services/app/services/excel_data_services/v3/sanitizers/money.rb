# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Sanitizers
      class Money < ExcelDataServices::V3::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::Money => ->(obj) { obj }
          }
        end
      end
    end
  end
end
