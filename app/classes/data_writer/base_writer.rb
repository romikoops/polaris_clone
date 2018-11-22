# frozen_string_literal: true

module DataWriter
  class BaseWriter
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

    attr_reader :tenant, :file_name, :sheets_data, :xlsx

    def initialize(tenant:, file_name:)
      @tenant = tenant
      @file_name = file_name.remove(/.xlsx$/) + '.xlsx'
      @sheets_data = nil
      @xlsx = nil
    end

    def perform
      @sheets_data = load_and_prepare_data
      @xlsx = WriteXLSX.new(file_path, tempdir: Rails.root.join('tmp', 'write_xlsx/').to_s)

      @sheets_data.each do |sheet_name, rows_data|
        worksheet = @xlsx.add_worksheet(sheet_name)
        raw_headers = extract_raw_headers(rows_data)
        headers = transform_headers(raw_headers)
        setup_worksheet(worksheet, headers.length)
        write_headers(worksheet, headers)
        write_rows_data(worksheet, raw_headers, rows_data)
      end

      @xlsx.close
    end

    def file_path
      Rails.root.join('tmp', @file_name) unless @file_name.nil?
    end

    private

    def load_and_prepare_data
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def transform_headers(raw_headers)
      raw_headers.map(&:upcase)
    end

    def extract_raw_headers(rows_data)
      rows_data.flat_map(&:keys).compact.uniq
    end

    def header_format
      return @format if @format
      @format = @xlsx.add_format
      @format.set_bold
      @format
    end

    def write_headers(worksheet, headers)
      worksheet.write_row(0, 0, headers, header_format)
    end

    def setup_worksheet(worksheet, col_count)
      worksheet.set_column(0, col_count - 1, 17) # set all columns to width 17
      worksheet.freeze_panes(1, 0) # freeze first row
    end

    def write_row(worksheet, start_row_idx, start_col_idx, raw_headers, row_data)
      row = raw_headers.map { |header| row_data[header] }
      worksheet.write_row(start_row_idx, start_col_idx, row)
    end

    def write_rows_data(worksheet, raw_headers, rows_data)
      rows_data.each_with_index do |row_data, i|
        write_row(worksheet, i + 1, 0, raw_headers, row_data)
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
