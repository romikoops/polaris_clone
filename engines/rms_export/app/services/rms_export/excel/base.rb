# frozen_string_literal: true

module RmsExport
  module Excel
    class Base
      def initialize(organization_id:, sheet_type:, options: {})
        @sheet_type = sheet_type
        @organization = Organizations::Organization.find_by(id: organization_id)
        @scope = ::OrganizationManager::ScopeService.new(organization: @organization).fetch
        file_name = options[:file_name] || "#{@organization.slug}_#{sheet_type}.xlsx"
        @file_name = file_name.remove(/.xlsx$/) + '.xlsx'
        @xlsx = nil
      end

      def self.write_document(options)
        new(options).perform
      end

      def load_book
        @book = RmsData::Book.find_by(organization: @organization, sheet_type: sheet_type)
      end

      def perform # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        load_book
        return nil unless @book

        tempfile = Tempfile.new('excel')
        @xlsx = WriteXLSX.new(tempfile, tempdir: Rails.root.join('tmp', 'write_xlsx/').to_s)

        @book.sheets.each do |sheet|
          @sheet = sheet
          worksheet = xlsx.add_worksheet(sheet.sheet_index)
          rows_data = sheet.rows
          next if rows_data.blank?

          write_headers(worksheet)
          write_rows_data(worksheet, rows_data)
        end

        xlsx.close

        Legacy::File.create!(
          text: file_name,
          doc_type: sheet_type,
          organization: @organization,
          file: {
            io: File.open(tempfile.path),
            filename: file_name,
            content_type: 'application/vnd.ms-excel'
          }
        )
      rescue StandardError
        raise
      ensure
        tempfile&.unlink
      end


      private

      attr_accessor :sheet_type, :book, :xlsx, :file_name, :tenant

      def header_format
        @header_format ||= xlsx.add_format(bold: 1)
      end

      def write_headers(worksheet)
        @sheet.headers.each do |cell|
          worksheet.write(cell.row, cell.column, cell.value, header_format)
        end
      end

      def format_and_write_row(worksheet, row_data)
        row_data.each do |cell|
          cell_content = cell.value
          if cell_content.is_a?(ActiveSupport::TimeWithZone)
            cell_content = cell_content.to_datetime.iso8601(3).remove(/\+.+$/)
            worksheet.write_date_time(cell.row, cell.column, cell_content, date_dd_mm_yyyy_format)
          else
            worksheet.write(cell.row, cell.column, cell_content)
          end
        end
      end

      def write_rows_data(worksheet, rows_data)
        rows_data.each do |row_data|
          format_and_write_row(worksheet, row_data)
        end
      end
    end
  end
end
