# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class LoadTypeType < ExcelDataServices::Validators::TypeValidity::Types::Base
          def valid?
            case value
            when String
              %w[cargo_item container].include?(value.downcase)
            else
              false
            end
          end
        end
      end
    end
  end
end
