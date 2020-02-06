# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class Schedules < ExcelDataServices::Restructurers::Base
      def perform
        { 'Schedules' => parse_cargo_class(rows_data: data[:rows_data], key: :load_type) }
      end
    end
  end
end
