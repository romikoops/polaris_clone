# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class ZoneType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              !value.match?(/-/) && /[0-9]{1,}/i.match?(value.delete(" "))
            when Integer
              true
            when Float
              !value.nan?
            when NilClass
              false
            end
          end
        end
      end
    end
  end
end
