# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class Schedules < ExcelDataServices::Rows::Base
      def closing_date
        @closing_date ||= data[:closing_date]
      end

      def eta
        @eta ||= data[:eta]
      end

      def etd
        @etd ||= data[:etd]
      end
    end
  end
end
