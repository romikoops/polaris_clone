# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class Distance < ExcelDataServices::V4::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::Float => ->(obj) { (string << integer).call(obj) },
            ::Integer => ->(obj) { (string << integer).call(obj) }
          }
        end
      end
    end
  end
end
