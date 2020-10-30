# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Coordinates
      class Range < ExcelDataServices::Schemas::Coordinates::Base
        def limits
          coordinates.split(":")
        end
      end
    end
  end
end
