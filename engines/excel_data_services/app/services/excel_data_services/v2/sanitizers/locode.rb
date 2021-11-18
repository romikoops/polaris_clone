# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Sanitizers
      class Locode < ExcelDataServices::V2::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::String => ->(obj) { (spaces << string).call(obj) }
          }
        end
      end
    end
  end
end
