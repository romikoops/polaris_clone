# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Coordinates
      class List < ExcelDataServices::Schemas::Coordinates::Base
        def perform
          coordinates.split(/[|,]/).map { |value| numerical_value(input: value) }
        end
      end
    end
  end
end
