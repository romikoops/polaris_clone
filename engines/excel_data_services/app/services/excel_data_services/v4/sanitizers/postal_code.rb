# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class PostalCode < ExcelDataServices::V4::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { obj },
            ::Integer => ->(obj) { string.call(obj) },
            ::Float => ->(obj) { (string << integer).call(obj) }
          }
        end
      end
    end
  end
end
