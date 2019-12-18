# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class Employees < ExcelDataServices::Restructurers::Base
      def perform
        restructured_data = data[:rows_data].map do |row|
          row[:address_id] = Legacy::Address.geocoded_address(row[:address]) if row[:address]
          row[:company] = Tenants::Company.find_by(
            name: row[:company_name],
            tenant: Tenants::Tenant.find_by(legacy_id: @tenant.id)
          )
          row[:email] = row[:email].downcase.strip
          password = row[:password].is_a?(Numeric) ? row[:password].to_i.to_s : row[:password]
          row[:password] = password.strip

          row
        end

        { 'Employees' => restructured_data }
      end
    end
  end
end
