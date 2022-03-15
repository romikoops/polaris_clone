# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Sanitizers
      class Distance < ExcelDataServices::V3::Sanitizers::Base
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
