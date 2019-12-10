# frozen_string_literal: true

require 'axlsx'

module AdmiraltyReports
  class ExcelGenerator
    def self.generate(raw_data:)
      new(raw_data: raw_data)
    end

    def initialize(raw_data:)
      @raw_data = raw_data
    end

    def process_excel_file
      excel_package = ::Axlsx::Package.new
      xlsx_content(excel_package.workbook)
      excel_package
    end

    private

    def xlsx_content(workbook)
      workbook.add_worksheet(name: 'Stat Overview') do |sheet|
        sheet.add_row ['Tenant Name', 'Date of Quotation/Booking', 'User', 'Agency', 'Status']
        @raw_data.each do |shipment|
          sheet.add_row(
            [shipment.tenant.name,
             shipment.updated_at,
             shipment&.user&.email,
             shipment&.user&.agency&.name,
             shipment.status]
          )
        end
      end
    end
  end
end
