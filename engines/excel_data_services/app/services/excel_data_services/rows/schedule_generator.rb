# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class ScheduleGenerator < ExcelDataServices::Rows::Base
      def ordinals
        @ordinals ||= data[:ordinals]
      end
    end
  end
end
