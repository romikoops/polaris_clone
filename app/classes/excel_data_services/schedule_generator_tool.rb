module ExcelDataServices
  module ScheduleGeneratorTool
    # UnknownRateBasisReadingError = Class.new(parent::FileParser::Base::ParsingError)
    # UnknownRateBasisWritingError = Class.new(parent::FileWriter::Base::WritingError)

    VALID_SCHEDULE_GENERATOR_HEADERS = %i(
      origin
      destination
      etd_days
      transit_time
      cargo_class
    ).freeze
  end
end
