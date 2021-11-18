# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class OptionalMonthType < ExcelDataServices::Validators::TypeValidity::Types::Base
          ACCEPTED_GERMAN_ABBREVIATIONS = %w[MAI OKT DEZ].freeze
          VALID_MONTHS = (ACCEPTED_GERMAN_ABBREVIATIONS + Date::ABBR_MONTHNAMES + Date::MONTHNAMES + %w[incl n/a]).compact.map(&:downcase).freeze

          def valid?
            case value
            when NilClass
              true
            when String
              VALID_MONTHS.include?(value.downcase)
            else
              false
            end
          end
        end
      end
    end
  end
end
