# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Sanitizers
      class Upcase < ExcelDataServices::V3::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (strip << upcase).call(obj) }
          }
        end
      end
    end
  end
end
