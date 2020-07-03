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
        sheet.add_row ['Tenant Name', 'Date of Quotation/Booking', 'User', 'Company', 'Status']
        @raw_request_data.each do |request|
          request_user = ::Users::User.find_by(id: request.user_id)
          request_organization = request.try(:organization) || Legacy::Shipment.find(request.original_shipment_id).organization
          company = Companies::Membership.find_by(member: request_user)&.company
          sheet.add_row(
            [request_organization.try(:name) || request_organization.try(:slug),
             request.created_at.to_date,
             request_user&.email,
             company&.name,
             request.try(:status)]
          )
        end
      end
    end
  end
end
