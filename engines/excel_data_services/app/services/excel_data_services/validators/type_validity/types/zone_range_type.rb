# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class ZoneRangeType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              value.match(/-/)
            when NilClass
              true
            when Float
              value.nan?
            when Integer
              false
            end
          end
        end
      end
    end
  end
end
