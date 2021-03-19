# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class Employees < ExcelDataServices::Restructurers::Base
      def perform
        restructured_data = data[:rows_data].map { |row|
          row[:address_id] = ::Legacy::Address.geocoded_address(row[:address]).id if row[:address]
          row[:company] = ::Companies::Company.find_by(
            name: row[:company_name],
            organization: @organization
          )
          row[:email] = row[:email].gsub(/[[:space:]]/, ' ').downcase.strip
          password = row[:password].is_a?(Numeric) ? row[:password].to_i.to_s : row[:password]
          row[:password] = password.strip

          row
        }

        {"Employees" => restructured_data}
      end
    end
  end
end
