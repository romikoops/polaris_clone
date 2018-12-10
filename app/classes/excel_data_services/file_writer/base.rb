# frozen_string_literal: true

module ExcelDataServices
  module FileWriter
    class Base
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

      def initialize(tenant_id:, file_name:)
        @tenant = Tenant.find(tenant_id)
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
      rescue => e
        binding.pry
      ensure
        binding.pry
        tempfile.unlink
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
        return @header_format if @header_format
        @header_format = xlsx.add_format
        @header_format.set_bold
        @header_format
      end

      def write_headers(worksheet, headers)
        worksheet.write_row(0, 0, headers, header_format)
      end

      def setup_worksheet(worksheet, col_count)
        worksheet.set_column(0, col_count - 1, 17) # set all columns to width 17
        worksheet.freeze_panes(1, 0) # freeze first row
      end

      def date_dd_mm_yyyy_format
        return @date_dd_mm_yyyy_format if @date_dd_mm_yyyy_format
        @date_dd_mm_yyyy_format = xlsx.add_format
        @date_dd_mm_yyyy_format.set_num_format('dd.mm.yyyy')
        @date_dd_mm_yyyy_format
      end

      def format_and_write_row(worksheet, start_row_idx, start_col_idx, raw_headers, row_data)
        raw_headers.each_with_index do |header, i|
          cell_content = row_data[header]

          if cell_content.is_a?(ActiveSupport::TimeWithZone)
            cell_content = cell_content.to_datetime.iso8601(3).remove(/\+.+$/)
            worksheet.write_date_time(start_row_idx, start_col_idx + i, cell_content, date_dd_mm_yyyy_format)
          else
            worksheet.write(start_row_idx, start_col_idx + i, cell_content)
          end
        end
      end

      def write_rows_data(worksheet, raw_headers, rows_data)
        rows_data.each_with_index do |row_data, i|
          format_and_write_row(worksheet, i + 1, 0, raw_headers, row_data)
        end
      end

      def remove_hub_suffix(name, mot)
        str_to_remove = case mot
                        when 'ocean' then 'Port'
                        when 'air'   then 'Airport'
                        when 'rail'  then 'Railyard'
                        when 'truck' then 'Depot'
                        end
        name.remove(/ #{str_to_remove}$/)
      end
    end
  end
end
