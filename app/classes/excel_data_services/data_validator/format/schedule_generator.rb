# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Format
      class ScheduleGenerator < ExcelDataServices::DataValidator::Format::Base
        private

        def check_row(_row)
        end

        def build_valid_headers(_data_extraction_method)
          %i(origin
             destination
             carrier
             service_level
             etd_days
             transit_time
             cargo_class)
        end
      end
    end
  end
end
