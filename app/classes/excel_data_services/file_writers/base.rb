# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class Base # rubocop:disable Metrics/ClassLength
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

      HEADER_COLLECTION = ExcelDataServices::DataValidators::HeaderChecker::StaticHeadersForDataRestructurers

      PRICING_COMMON_LOOKUP = {
        effective_date: :effective_date,
        expiration_date: :expiration_date,
        customer_email: :customer_email,
        origin: :origin_hub_name,
        country_origin: :origin_country_name,
        destination: :destination_hub_name,
        country_destination: :destination_country_name,
        mot: :mot,
        carrier: :carrier_name,
        service_level: :service_level,
        load_type: :load_type,
        rate_basis: :rate_basis,
        currency: :currency_name
      }.freeze

      PRICING_ONE_COL_FEE_AND_RANGES_LOOKUP = PRICING_COMMON_LOOKUP.merge(
        range_min: :range_min,
        range_max: :range_max,
        fee_code: :shipping_type,
        fee_name: :fee_name,
        fee_min: :min,
        fee: :rate
      ).freeze

      PRICING_DYNAMIC_FEE_COLS_NO_RANGES_LOOKUP = PRICING_COMMON_LOOKUP.merge(
        transit_time: :transit_time
      ).freeze

      def self.write_document(options)
        new(options).perform
      end

      def initialize(tenant:, file_name:, sandbox: nil)
        @tenant = tenant
        @tenants_tenant = Tenants::Tenant.find_by(legacy_id: tenant&.id)
        @scope = ::Tenants::ScopeService.new(tenant: tenants_tenant).fetch
        @file_name = file_name.remove(/.xlsx$/) + '.xlsx'
        @xlsx = nil
        @sandbox = sandbox
      end

      def perform # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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

      attr_reader :tenant, :file_name, :xlsx, :tenants_tenant, :scope

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
        @header_format ||= xlsx.add_format(bold: 1)
      end

      def write_headers(worksheet, headers)
        worksheet.write_row(0, 0, headers, header_format)
      end

      def setup_worksheet(worksheet, _col_count)
        worksheet.freeze_panes(1, 0) # freeze first row
        worksheet.set_column('A:ZZ', 17) # set columns to width 17
      end

      def date_dd_mm_yyyy_format
        @date_dd_mm_yyyy_format ||= xlsx.add_format(num_format: 'dd.mm.yyyy')
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
        str_to_remove = { 'ocean' => 'Port',
                          'air' => 'Airport',
                          'rail' => 'Railyard',
                          'truck' => 'Depot' }[mot]

        name.remove(/ #{str_to_remove}$/)
      end
    end
  end
end
