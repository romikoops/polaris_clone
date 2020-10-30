# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class DirectionType < ExcelDataServices::Validators::TypeValidity::Types::Base
          DIRECTIONS = %w[import export].freeze
          def valid?
            case value
            when String
              DIRECTIONS.include?(value.downcase)
            else
              false
            end
          end
        end
      end
    end
  end
end
