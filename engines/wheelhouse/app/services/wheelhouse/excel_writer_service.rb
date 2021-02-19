# frozen_string_literal: true

module Wheelhouse
  class ExcelWriterService
    SUMMARY_SHEET_LOOKUP = {
      Origin: :origin,
      Destination: :destination,
      Carrier: :carrier,
      Service: :service_level,
      Transshipment: :transshipment,
      'Mode of transport': :mode_of_transport,
      Total: :total
    }

    TENDER_FEES_LOOKUP = {
      description: :description,
      total: :total
    }

    TENDER_DETAILS_LOOKUP = {
      **SUMMARY_SHEET_LOOKUP,
      'Load type': :load_type,
      'Pick up service': :pre_carriage_service,
      'Delivery service': :on_carriage_service,
      'Pickup carrier': :pre_carriage_carrier,
      'Delivery carrier': :on_carriage_carrier

    }
    SUMMARY_SHEET_TITLE = "Summary"
    XLSX_SHEET_NAME_LIMIT = 25

    attr_reader :work_book

    def initialize(offer:)
      @offer = offer
      @tempfile = Tempfile.new([file_name, ".xlsx"])
      @scope = OrganizationManager::ScopeService.new(
        target: offer.query.client, organization: offer.query.organization
      ).fetch
      @base_spacing = 2
    end

    def quotation_sheet
      prepare_sheets
      tempfile
    end

    private

    attr_reader :offer, :result_ids, :results, :tempfile, :charges, :scope, :base_spacing, :remarks_index

    def prepare_sheets
      @work_book = WriteXLSX.new(tempfile, tempdir: Rails.root.join("tmp", "write_xlsx").to_s)
      create_summary_sheet
      populate_result_sheets
      work_book.close
    end

    def currency_headers
      %i[total value]
    end

    def create_summary_sheet
      summary_sheet = work_book.add_worksheet(SUMMARY_SHEET_TITLE)
      summary_sheet.write_row(0, 0, SUMMARY_SHEET_LOOKUP.keys, header_format)
      selected_results.each_with_index do |result, row_index|
        SUMMARY_SHEET_LOOKUP.values.each_with_index do |value, col_index|
          cell_value = if currency_headers.include?(value)
            result.send(value).format
          else
            result.send(value)
          end

          summary_sheet.write(row_index + 1, col_index, cell_value)
        end
      end
    end

    def populate_result_sheets
      selected_results.each do |result|
        create_result_entry(result: result)
      end
    end

    def create_result_entry(result:)
      sheet = work_book.add_worksheet(result_sheet_name(result: result))
      sheet.write_row(0, 0, TENDER_DETAILS_LOOKUP.keys, header_format)
      write_result_entry(sheet: sheet, result: result, row_index: 1, lookup: TENDER_DETAILS_LOOKUP)
      write_line_items(result: result, sheet: sheet)
      write_remarks(result: result, sheet: sheet)
      write_validity(result: result, sheet: sheet)
      write_exchange_rates(result: result, sheet: sheet)
    end

    def write_line_items(result:, sheet:)
      header_row_index = base_spacing + 2
      TENDER_FEES_LOOKUP.keys.each_with_index do |key, index|
        sheet.write(header_row_index, index, "Fees (#{key})", header_format)
      end
      line_items = ResultFormatter::LineItemDecorator
        .decorate_collection(result.line_items, context: {scope: scope})
      line_items.each_with_index do |line_item, row_index|
        TENDER_FEES_LOOKUP.values.each_with_index do |value, col_index|
          value = format_cell_value(header: value, line_item: line_item)
          sheet.write(header_row_index + row_index + 1, col_index, value)
        end
      end
    end

    def write_remarks(result:, sheet:)
      @remarks_index = result.line_items.count + (base_spacing + 4)
      sheet.write(remarks_index, 0, "Remarks", header_format)
      if query.remarks.blank?
        sheet.write(remarks_index + 1, 0, "-")
      else
        query.remarks.each_with_index do |remark, index|
          sheet.write(remarks_index + index + 1, 0, remark.body)
        end
      end
    end

    def write_validity(result:, sheet:)
      validity_row_index = remarks_index + query.remarks.count + base_spacing + 1
      formatted_expiry = result.valid_until&.strftime("%F")
      sheet.write_row(validity_row_index, 0, ["Prices valid until", formatted_expiry])
    end

    def write_exchange_rates(result:, sheet:)
      exchange_rates = result.exchange_rates
      return if exchange_rates.blank?

      target_row = remarks_index + query.remarks.count + (base_spacing * 3)
      sheet.write(target_row, 0, "Exchange Rates", header_format)
      exchange_rates.except("base").keys.each_with_index do |key, index|
        target_index = target_row + index + 1
        rate = exchange_rates.dig(key).ceil(5)
        row_entry = ["1 #{exchange_rates.dig("base")}", "#{rate} #{key.upcase}"]
        sheet.write_row(target_index, 0, row_entry)
      end
    end

    def format_currency(value:)
      "#{value.dig(:currency)} #{value.dig(:amount)}"
    end

    def format_cell_value(header:, line_item:)
      case header
      when :total
        line_item.total.format
      when :description
        line_item.description
      end
    end

    def write_result_entry(sheet:, result:, row_index:, lookup:)
      lookup.values.each_with_index do |value, col_index|
        cell_value = if currency_headers.include?(value)
          result.send(value).format
        else
          result.send(value) || "-"
        end

        sheet.write(row_index, col_index, cell_value)
      end
    end

    def selected_results
      @selected_results ||= offer.results.map { |result|
        ResultFormatter::ResultDecorator.new(result, context: {scope: scope})
      }
    end

    def file_name
      @file_name ||= begin
        quotation_file_name = "Quotation_#{format_datetime(date: query.created_at)}"
        Pathname.new(quotation_file_name).sub_ext(".xlsx").to_s
      end
    end

    def header_format
      @header_format ||= work_book.add_format(bold: 1)
    end

    def result_sheet_name(result:)
      service_level = result.service_level.capitalize
      carrier = result.carrier&.capitalize || ""
      name = "#{result.origin}-#{result.destination}-#{carrier}-#{service_level}"[0..XLSX_SHEET_NAME_LIMIT]
      sheet_names = work_book.sheets.map { |sheet| sheet.name.split("_").first }
      sheet_names.include?(name) ? "#{name}_#{sheet_names.count(name) + 1}" : name
    end

    def format_datetime(date:)
      date.strftime("%F %H:%M:%S")
    end

    def query
      @query ||= ResultFormatter::QueryDecorator.new(offer.query, context: {scope: scope})
    end
  end
end
