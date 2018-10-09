# frozen_string_literal: true

module DataWriter
  class BaseWriter
    attr_reader :xlsx, :sheets_data

    def initialize(file_name:, sheets_data:)
      # DEBUG
      sheets_data = JSON.parse('{"Tabelle1":[{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"CMA CGM","service_level":"standard","load_type":"fcl_20","transit_time":20,"currency":"USD","fees":{"bas":"USD 550","lss":50,"efs__ebs":45}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"CMA CGM","service_level":"standard","load_type":"fcl_40","transit_time":20,"currency":"USD","fees":{"bas":"USD 850","lss":100,"efs__ebs":90}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"CMA CGM","service_level":"standard","load_type":"fcl_40_hq","transit_time":20,"currency":"USD","fees":{"bas":"USD 850","lss":100,"efs__ebs":90}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"MSC","service_level":"standard","load_type":"fcl_20","transit_time":20,"currency":"USD","fees":{"bas":"USD 550","lss":30,"efs__ebs":35}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"MSC","service_level":"standard","load_type":"fcl_40","transit_time":20,"currency":"USD","fees":{"bas":"USD 875","lss":60,"efs__ebs":70}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"MSC","service_level":"standard","load_type":"fcl_40_hq","transit_time":20,"currency":"USD","fees":{"bas":"USD 875","lss":60,"efs__ebs":70}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"COSCO","service_level":"standard","load_type":"fcl_20","transit_time":20,"currency":"USD","fees":{"bas":"USD 550","lss":null,"efs__ebs":50}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"COSCO","service_level":"standard","load_type":"fcl_40","transit_time":20,"currency":"USD","fees":{"bas":"USD 875","lss":null,"efs__ebs":100}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"COSCO","service_level":"standard","load_type":"fcl_40_hq","transit_time":20,"currency":"USD","fees":{"bas":"USD 875","lss":null,"efs__ebs":100}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"CMA CGM","service_level":"standard","load_type":"fcl_20","transit_time":20,"currency":"USD","fees":{"bas":"USD 550","lss":null,"efs__ebs":null}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"CMA CGM","service_level":"standard","load_type":"fcl_40","transit_time":20,"currency":"USD","fees":{"bas":"USD 850","lss":null,"efs__ebs":null}},{"effective_date":"2018-07-01","expiration_date":"2019-03-20","customer_email":null,"origin":"Hamburg","destination":"Guayaquil","mot":"ocean","carrier":"CMA CGM","service_level":"standard","load_type":"fcl_40_hq","transit_time":20,"currency":"USD","fees":{"bas":"USD 850","lss":null,"efs__ebs":null}}]}')
      # /DEBUG

      @file_name = file_name
      @sheets_data = sheets_data
      @xlsx = nil
      @stats = {}
      post_initialize
    end

    def perform
      @xlsx = WriteXLSX.new(file_path, tempdir: Rails.root.join('tmp', 'write_xlsx/').to_s)

      @sheets_data.each do |sheet_name, rows|
        worksheet = @xlsx.add_worksheet(sheet_name)
        headers = extract_headers(rows.first)
        write_headers(worksheet, headers)
        setup_worksheet(worksheet, headers.length)
        write_rows_data(worksheet, rows)
      end

      @xlsx.close
      stats
    end

    def stats
      @stats.merge!(local_stats)
    end

    private

    def file_path
      Rails.root.join('tmp', @file_name)
    end

    def extract_raw_headers(_first_row)
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def transform_headers(headers)
      headers.map(&:upcase)
    end

    def extract_headers(first_row)
      raw_headers = extract_raw_headers(first_row)
      transform_headers(raw_headers)
    end

    def header_format
      format = @xlsx.add_format
      format.set_bold
      format
    end

    def write_headers(worksheet, headers)
      worksheet.write_row(0, 0, headers, header_format)
    end

    def setup_worksheet(worksheet, col_count)
      worksheet.set_column(0, col_count - 1, 17) # set all columns to width 17
      worksheet.freeze_panes(1, 0) # freeze first row
    end

    def extract_row(_row_data)
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def write_row(worksheet, start_row_idx, start_col_idx, row_data)
      row = extract_row(row_data)
      worksheet.write_row(start_row_idx, start_col_idx, row)
    end

    def write_rows_data(worksheet, rows)
      rows.each_with_index do |row_data, i|
        write_row(worksheet, i + 1, 0, row_data)
      end
    end

    def post_initialize
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end

    def local_stats
      raise NotImplementedError, "This method must be implemented in #{self.class.name}."
    end
  end
end
