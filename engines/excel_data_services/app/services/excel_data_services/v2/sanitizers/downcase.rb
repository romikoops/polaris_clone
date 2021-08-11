# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Sanitizers
      class Downcase < ExcelDataServices::V2::Sanitizers::Text
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (strip << downcase).call(obj) }
          }
        end
      end
    end
  end
end
