# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class TruckTypeType < ExcelDataServices::Validators::TypeValidity::Types::Base
          TRUCK_TYPES = %w[default side_lifter chassis].freeze
          def valid?
            case value
            when String
              TRUCK_TYPES.include?(value.downcase)
            else
              false
            end
          end
        end
      end
    end
  end
end
