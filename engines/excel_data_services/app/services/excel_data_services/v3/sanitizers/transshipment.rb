# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Sanitizers
      class Transshipment < ExcelDataServices::V3::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (direct_as_nil).call(obj) }
          }
        end
      end
    end
  end
end
