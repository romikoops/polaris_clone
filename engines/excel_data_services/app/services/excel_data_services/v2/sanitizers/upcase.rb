# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Sanitizers
      class Upcase < ExcelDataServices::V2::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (strip << upcase).call(obj) }
          }
        end
      end
    end
  end
end
