# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class Companies < ExcelDataServices::Restructurers::Base
      def perform
        restructured_data = data[:rows_data].map do |row|
          row[:address_id] = Legacy::Address.geocoded_address(row[:address])&.id

          row
        end

        { 'Companies' => restructured_data }
      end
    end
  end
end
