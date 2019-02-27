# frozen_string_literal: true

module ExcelDataServices
  module ScheduleGeneratorTool
    VALID_SCHEDULE_GENERATOR_HEADERS = %i(
      origin
      destination
      etd_days
      transit_time
      cargo_class
    ).freeze
  end
end
