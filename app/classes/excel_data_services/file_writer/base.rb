# frozen_string_literal: true

module ExcelDataServices
  module FileWriter
    class Base
      WritingError = Class.new(StandardError)
      UnknownSheetNameError = Class.new(WritingError)

      # Expected data structure:
      # {
      #   Sheet1: [
      #     {
      #       header1: "...",
      #       header2: 0.0,
      #       ...
      #     },
      #     {
      #       ...
      #     }
      #   ],
      #   Sheet2: [
      #     {
      #       ...
      #     }
      #   ]
      # }

      attr_reader :tenant, :file_name, :xlsx

      def initialize(tenant:, file_name:)
        @tenant = tenant
        @file_name = file_name.remove(/.xlsx$/) + '.xlsx'
        @xlsx = nil
      end

      def perform
        sheets_data = load_and_prepare_data

        tempfile = Tempfile.new('excel')
        @xlsx = WriteXLSX.new(tempfile, tempdir: Rails.root.join('tmp', 'write_xlsx/').to_s)

        sheets_data.each do |sheet_name, rows_data|
          worksheet = xlsx.add_worksheet(sheet_name)
          next if rows_data.blank?

          raw_headers = build_raw_headers(sheet_name, rows_data)
          headers = transform_headers(raw_headers)
          setup_worksheet(worksheet, headers.length)
          write_headers(worksheet, headers)
          write_rows_data(worksheet, raw_headers, rows_data)
        end

        xlsx.close

        Document.create!(
          text: file_name,
          doc_type: 'pricing',
          tenant: tenant,
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

      def load_and_prepare_data
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      def transform_headers(raw_headers)
        raw_headers.map(&:upcase)
      end

      def build_raw_headers(_sheet_name, _rows_data)
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      def header_format
        @header_format ||= xlsx.add_format(locked: 0, bold: 1)
      end

      def uuid_format
        @uuid_format ||= xlsx.add_format(locked: 1)
      end

      def cell_format
        @cell_format ||= xlsx.add_format(locked: 0)
      end

      def write_headers(worksheet, headers)
        worksheet.write_row(0, 0, headers, header_format)
      end

      def setup_worksheet(worksheet, _col_count)
        worksheet.freeze_panes(1, 0) # freeze first row
        worksheet.set_column('A:A', 17, uuid_format) # set first column to width 17 and lock
        worksheet.set_column('B:XFD', 17, cell_format) # set all other columns to width 17 and unlocked
        worksheet.protect # enable protections
      end

      def date_dd_mm_yyyy_format
        @date_dd_mm_yyyy_format ||= xlsx.add_format(num_format: 'dd.mm.yyyy', locked: 0)
      end

      def format_and_write_row(worksheet, start_row_idx, start_col_idx, raw_headers, row_data)
        raw_headers.each_with_index do |header, i|
          cell_content = row_data[header]
          if cell_content.is_a?(ActiveSupport::TimeWithZone)
            cell_content = cell_content.to_datetime.iso8601(3).remove(/\+.+$/)
            worksheet.write_date_time(start_row_idx, start_col_idx + i, cell_content, date_dd_mm_yyyy_format)
          else
            worksheet.write(start_row_idx, start_col_idx + i, cell_content, (header == :uuid ? uuid_format : cell_format))
          end
        end
      end

      def write_rows_data(worksheet, raw_headers, rows_data)
        rows_data.each_with_index do |row_data, i|
          format_and_write_row(worksheet, i + 1, 0, raw_headers, row_data)
        end
      end

      def remove_hub_suffix(name, mot)
        str_to_remove = { 'ocean' => 'Port',
                          'air' => 'Airport',
                          'rail' => 'Railyard',
                          'truck' => 'Depot' }[mot]

        name.remove(/ #{str_to_remove}$/)
      end
    end
  end
end
