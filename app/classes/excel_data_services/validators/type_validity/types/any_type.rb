# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class AnyType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            true
          end
        end
      end
    end
  end
end
