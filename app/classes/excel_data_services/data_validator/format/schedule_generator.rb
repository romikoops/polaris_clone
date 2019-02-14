# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Format
      class ScheduleGenerator < Base
        private

        def check_row(row)
          # raise NotImplementedError
        end

        def build_valid_headers(_data_extraction_method)
          %i(origin
            destination
            etd_days
            transit_time
            cargo_class)
        end
      end
    end
  end
end
