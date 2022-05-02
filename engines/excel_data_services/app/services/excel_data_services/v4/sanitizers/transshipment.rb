# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class Transshipment < ExcelDataServices::V4::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (direct_as_nil).call(obj) }
          }
        end
      end
    end
  end
end
