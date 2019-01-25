# frozen_string_literal: true

module ExcelDataServices
  module ChargeCategoryTool
    UnknownRateBasisReadingError = Class.new(parent::FileParser::Base::ParsingError)
    UnknownRateBasisWritingError = Class.new(parent::FileWriter::Base::WritingError)

    VALID_CHARGE_HEADERS = %i(
      internal_code
      fee_code
      fee_name
    ).freeze
  end
end
