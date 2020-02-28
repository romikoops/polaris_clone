# frozen_string_literal: true

require 'axlsx'

module AdmiraltyReports
  class ExcelGenerator
    def self.generate(raw_request_data:)
      new(raw_request_data: raw_request_data)
    end

    def initialize(raw_request_data:)
      @raw_request_data = raw_request_data
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
        @raw_request_data.each do |request|
          request_user = request&.user
          request_tenant = request.try(:tenant) || Legacy::Shipment.find(request.original_shipment_id).tenant
          sheet.add_row(
            [request_tenant.try(:name) || request_tenant.try(:slug),
             request.updated_at.to_date,
             request_user&.email,
             request_user&.agency&.name,
             request.try(:status)]
          )
        end
      end
    end
  end
end
