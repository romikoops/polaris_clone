# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Sanitizers
      class Downcase < ExcelDataServices::V3::Sanitizers::Text
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (strip << downcase).call(obj) }
          }
        end
      end
    end
  end
end
