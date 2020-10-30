# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Targets
      class Relative < ExcelDataServices::Schemas::Targets::Base
        private

        def raw_data
          @raw_data ||= ExcelDataServices::Schemas::Coordinates::Relative.new(
            source: source, section: section, axis: axis
          ).perform
        end
      end
    end
  end
end
