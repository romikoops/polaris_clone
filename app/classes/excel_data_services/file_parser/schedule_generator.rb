# frozen_string_literal: true

module ExcelDataServices
  module FileParser
    class ScheduleGenerator < Base
      include ExcelDataServices::ScheduleGeneratorTool
      include DataRestructurer::ScheduleGenerator

      private

      def build_valid_headers(_data_extraction_method)
        VALID_SCHEDULE_GENERATOR_HEADERS
      end

      def sanitize_row_data(row_data)
        strip_whitespaces(row_data)
      end
    end
  end
end
