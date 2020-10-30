# frozen_string_literal: true

module ExcelDataServices
  module Rows
    class Hubs < ExcelDataServices::Rows::Base
      def locode
        @locode ||= data.dig(:locode) || data.dig(:address, :locode)
      end
    end
  end
end
