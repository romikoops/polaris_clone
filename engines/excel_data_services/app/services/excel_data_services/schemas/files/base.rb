# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Files
      class Base
        def initialize(file:)
          @file = file
        end

        private

        attr_reader :file
      end
    end
  end
end
