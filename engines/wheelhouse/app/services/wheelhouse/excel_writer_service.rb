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
      'Pick up service': :pickup_service,
      'Delivery service': :delivery_service,
      'Pickup carrier': :pickup_carrier,
      'Delivery carrier': :delivery_carrier

    }
    SUMMARY_SHEET_TITLE = "Summary"
    XLSX_SHEET_NAME_LIMIT = 25

    attr_reader :work_book

    def initialize(quotation_id:, tender_ids:, scope: {})
      @quotation = Quotations::Quotation.find(quotation_id)
      @tender_ids = tender_ids.presence || quotation.tenders.ids
      @tempfile = Tempfile.new([file_name, ".xlsx"])
      @scope = scope
      @base_spacing = 2
    end

    def quotation_sheet
      prepare_sheets
      Legacy::File.create!(
        text: file_name,
        doc_type: "Quotations::Quotation",
        organization: quotation.organization,
        user: quotation.user,
        file: {
          io: File.open(tempfile.path),
          filename: file_name,
          content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        }
      )
    ensure
      tempfile&.unlink
    end

    private

    attr_reader :quotation, :tender_ids, :tenders, :tempfile, :charges, :scope, :base_spacing, :remarks_index

    def prepare_sheets
      @work_book = WriteXLSX.new(tempfile, tempdir: Rails.root.join("tmp", "write_xlsx").to_s)
      create_summary_sheet
      populate_tender_sheets
      work_book.close
    end

    def currency_headers
      %i[total value]
    end

    def create_summary_sheet
      summary_sheet = work_book.add_worksheet(SUMMARY_SHEET_TITLE)
      summary_sheet.write_row(0, 0, SUMMARY_SHEET_LOOKUP.keys, header_format)
      quotation_tenders.each_with_index do |tender, row_index|
        SUMMARY_SHEET_LOOKUP.values.each_with_index do |value, col_index|
          cell_value = if currency_headers.include?(value)
            format_currency(value: tender.send(value))
          else
            tender.send(value)
          end

          summary_sheet.write(row_index + 1, col_index, cell_value)
        end
      end
    end

    def populate_tender_sheets
      selected_tenders.each do |tender|
        create_tender_entry(tender: tender)
      end
    end

    def create_tender_entry(tender:)
      sheet = work_book.add_worksheet(tender_sheet_name(tender: tender))
      sheet.write_row(0, 0, TENDER_DETAILS_LOOKUP.keys, header_format)
      write_tender_entry(sheet: sheet, tender: tender, row_index: 1, lookup: TENDER_DETAILS_LOOKUP)
      write_line_items(tender: tender, sheet: sheet)
      write_remarks(tender: tender, sheet: sheet)
      write_validity(tender: tender, sheet: sheet)
      write_exchange_rates(tender: tender, sheet: sheet)
    end

    def write_line_items(tender:, sheet:)
      header_row_index = base_spacing + 2
      TENDER_FEES_LOOKUP.keys.each_with_index do |key, index|
        sheet.write(header_row_index, index, "Fees (#{key})", header_format)
      end
      line_items = ResultFormatter::LineItemDecorator
        .decorate_collection(tender.line_items, context: {scope: scope})
      line_items.each_with_index do |line_item, row_index|
        TENDER_FEES_LOOKUP.values.each_with_index do |value, col_index|
          value = format_cell_value(header: value, line_item: line_item)
          sheet.write(header_row_index + row_index + 1, col_index, value)
        end
      end
    end

    def write_remarks(tender:, sheet:)
      @remarks_index = tender.line_items.count + (base_spacing + 4)
      sheet.write(remarks_index, 0, "Remarks", header_format)
      if tender.remarks.empty?
        sheet.write(remarks_index + 1, 0, "-")
      else
        tender.remarks.each_with_index do |remark, index|
          sheet.write(remarks_index + index + 1, 0, remark)
        end
      end
    end

    def write_validity(tender:, sheet:)
      validity_row_index = remarks_index + tender.remarks.count + base_spacing + 1
      formatted_expiry = tender.valid_until&.strftime("%F")
      sheet.write_row(validity_row_index, 0, ["Prices valid until", formatted_expiry])
    end

    def write_exchange_rates(tender:, sheet:)
      exchange_rates = ResultFormatter::ExchangeRateService.new(tender: tender).perform
      return if exchange_rates.blank?

      target_row = remarks_index + tender.remarks.count + (base_spacing * 3)
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

    def write_tender_entry(sheet:, tender:, row_index:, lookup:)
      lookup.values.each_with_index do |value, col_index|
        cell_value = if currency_headers.include?(value)
          format_currency(value: tender.send(value))
        else
          tender.send(value) || "-"
        end

        sheet.write(row_index, col_index, cell_value)
      end
    end

    def selected_tenders
      @selected_tenders ||= begin
        tenders = Quotations::Tender.where(id: tender_ids)
        Wheelhouse::TenderDecorator.decorate_collection(tenders)
      end
    end

    def file_name
      @file_name ||= begin
        quotation_file_name = "Quotation_#{format_datetime(date: quotation.created_at)}"
        Pathname.new(quotation_file_name).sub_ext(".xlsx").to_s
      end
    end

    def quotation_tenders
      @quotation_tenders ||= Wheelhouse::TenderDecorator.decorate_collection(quotation.tenders)
    end

    def header_format
      @header_format ||= work_book.add_format(bold: 1)
    end

    def tender_sheet_name(tender:)
      service_level = tender.service_level.capitalize
      carrier = tender.carrier&.capitalize || ""
      name = "#{tender.origin}-#{tender.destination}-#{carrier}-#{service_level}"[0..XLSX_SHEET_NAME_LIMIT]
      sheet_names = work_book.sheets.map { |sheet| sheet.name.split("_").first }
      sheet_names.include?(name) ? "#{name}_#{sheet_names.count(name) + 1}" : name
    end

    def format_datetime(date:)
      date.strftime("%F %H:%M:%S")
    end
  end
end
