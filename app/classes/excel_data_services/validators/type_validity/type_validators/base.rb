# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module TypeValidators
        class Base < ExcelDataServices::Validators::Base
          def initialize(value)
            @value = value
          end

          def valid?
            valid_types_with_values.each do |type, lambd|
              next unless value.is_a?(type)

              return lambd.call(value)
            end

            false
          end

          private

          attr_reader :value
        end
      end
    end
  end
end
