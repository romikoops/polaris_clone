# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      module Types
        class Base < ExcelDataServices::Validators::Base
          def initialize(value)
            @value = value
          end

          def valid?
            raise NotImplementedError, "This method must be implemented in #{self.class.name}."
          end

          private

          attr_reader :value
        end
      end
    end
  end
end
