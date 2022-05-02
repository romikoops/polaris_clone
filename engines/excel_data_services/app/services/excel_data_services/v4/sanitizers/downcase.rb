# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class Downcase < ExcelDataServices::V4::Sanitizers::Text
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (strip << downcase).call(obj) }
          }
        end
      end
    end
  end
end
