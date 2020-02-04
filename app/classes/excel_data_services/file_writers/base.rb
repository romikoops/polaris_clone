# frozen_string_literal: true

module ExcelDataServices
  module FileWriters
    class Base < ExcelDataServices::Base # rubocop:disable Metrics/ClassLength
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

      HEADER_COLLECTION = ExcelDataServices::Validators::HeaderChecker::StaticHeadersForRestructurers

      PRICING_COMMON_LOOKUP = {
        group_id: :group_id,
        group_name: :group_name,
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

      def self.get(category_identifier)
        "ExcelDataServices::FileWriters::#{category_identifier.camelize}".constantize
      end

      def self.write_document(options)
        new(options).perform
      end

      def initialize(tenant:, file_name:, user:, sandbox:, options:)
        @tenant = tenant
        @user = user
        @sandbox = sandbox
        @options = options

        @tenants_tenant = Tenants::Tenant.find_by(legacy_id: tenant.id)
        @scope = ::Tenants::ScopeService.new(tenant: tenants_tenant, target: user).fetch
        @file_name = Pathname.new(file_name).sub_ext('.xlsx').to_s
        @xlsx = nil
      end

      def perform # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        sheets_data = load_and_prepare_data

        tempfile = Tempfile.new('excel')
        @xlsx = WriteXLSX.new(tempfile, tempdir: Rails.root.join('tmp/write_xlsx/').to_s)

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

      attr_reader :tenant, :file_name, :xlsx, :tenants_tenant, :scope, :options

      def load_and_prepare_data
        raise NotImplementedError, "This method must be implemented in #{self.class.name}."
      end

      def transform_headers(raw_headers)
        raw_headers.map(&:upcase)
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

      def build_dynamic_headers(raw_pricing_rows)
        raw_pricing_rows.map { |row| row[:shipping_type]&.downcase&.to_sym }.uniq.compact.sort
      end

      def merge_grouped_rows(grouped_rows)
        grouped_rows.map do |group|
          group.reduce({}) do |memo, obj|
            # Values that are not nil take precedence
            memo.merge!(obj) { |_key, old_val, new_val| new_val.nil? ? old_val : new_val }
          end
        end
      end

      def group_by_static_headers(data_with_dynamic_headers)
        groups_hsh = data_with_dynamic_headers.group_by do |el|
          el.values_at(*HEADER_COLLECTION::PRICING_DYNAMIC_FEE_COLS_NO_RANGES)
        end

        groups_hsh.values
      end

      def build_rows_with_dynamic_headers(data_with_dynamic_headers, dynamic_headers)
        return if data_with_dynamic_headers.empty? || dynamic_headers.empty?

        PricingsRowDataBuilder.sort!(data_with_dynamic_headers)
        unmerged_rows = data_with_dynamic_headers.map do |attributes|
          row_data = {}

          PRICING_DYNAMIC_FEE_COLS_NO_RANGES_LOOKUP.each do |key, value|
            row_data[key] = attributes[value]
          end

          # Fill all dynamic headers with nil
          dynamic_headers.each do |key|
            row_data.merge!(key => nil)
          end

          # Overwrite the one existing dynamic header with the correct value
          header = attributes[:shipping_type]&.downcase&.to_sym
          row_data[header] = attributes[:rate]

          row_data
        end

        grouped_rows = group_by_static_headers(unmerged_rows)
        merge_grouped_rows(grouped_rows)
      end

      def build_raw_headers(sheet_name, rows_data)
        case sheet_name.to_s
        when 'No Ranges'
          dynamic_headers =
            rows_data.flat_map(&:keys).compact.uniq -
            HEADER_COLLECTION::OPTIONAL_PRICING_DYNAMIC_FEE_COLS_NO_RANGES -
            HEADER_COLLECTION::PRICING_DYNAMIC_FEE_COLS_NO_RANGES

          HEADER_COLLECTION::OPTIONAL_PRICING_DYNAMIC_FEE_COLS_NO_RANGES +
            HEADER_COLLECTION::PRICING_DYNAMIC_FEE_COLS_NO_RANGES +
            dynamic_headers
        when 'With Ranges'
          HEADER_COLLECTION::OPTIONAL_PRICING_ONE_COL_FEE_AND_RANGES +
            HEADER_COLLECTION::PRICING_ONE_COL_FEE_AND_RANGES
        else
          raise ExcelDataServices::Validators::ValidationErrors::WritingError::UnknownSheetNameError,
                "Unknown sheet name \"#{sheet_name}\"!"
        end
      end
    end
  end
end
