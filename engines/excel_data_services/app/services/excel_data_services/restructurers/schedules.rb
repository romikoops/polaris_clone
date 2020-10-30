# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class Schedules < ExcelDataServices::Restructurers::Base
      def perform
        restructured_data = sanitize_service_level_and_carrier(data[:rows_data])
        restructured_data = parse_cargo_class(rows_data: restructured_data, key: :load_type)

        {"Schedules" => restructured_data}
      end
    end
  end
end
