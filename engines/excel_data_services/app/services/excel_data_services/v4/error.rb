# frozen_string_literal: true

module ExcelDataServices
  module V4
    Error = Struct.new(:type, :row_nr, :col_nr, :sheet_name, :reason, :exception_class, keyword_init: true)
  end
end
