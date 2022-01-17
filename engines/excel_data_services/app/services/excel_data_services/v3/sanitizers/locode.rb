# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Sanitizers
      class Locode < ExcelDataServices::V3::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (spaces << string).call(obj) }
          }
        end
      end
    end
  end
end
