# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Targets
      class Range < ExcelDataServices::Schemas::Targets::Base
        private

        def raw_data
          @raw_data ||= ExcelDataServices::Schemas::Coordinates::Range.new(
            source: source, section: section, axis: axis
          ).perform
        end
      end
    end
  end
end
