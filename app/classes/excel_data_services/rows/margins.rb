# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class Margins < Base
      def itinerary_name
        @itinerary_name ||= [data[:origin], data[:destination]].join(' - ')
      end

      def operator
        @operator ||= data[:operator]
      end

      def margin
        @margin ||= data[:margin]
      end
    end
  end
end
