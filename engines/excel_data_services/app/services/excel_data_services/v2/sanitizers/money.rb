# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Sanitizers
      class Money < ExcelDataServices::V2::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::Money => ->(obj) { obj }
          }
        end
      end
    end
  end
end
