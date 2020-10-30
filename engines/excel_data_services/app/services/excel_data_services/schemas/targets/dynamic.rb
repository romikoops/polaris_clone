# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Targets
      class Dynamic < ExcelDataServices::Schemas::Targets::Base
        private

        def raw_data
          @raw_data ||= ExcelDataServices::Schemas::Coordinates::Dynamic.extract(
            source: source, section: section, axis: axis
          )
        end
      end
    end
  end
end
