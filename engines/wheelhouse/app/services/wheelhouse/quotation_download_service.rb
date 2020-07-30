# frozen_string_literal: true

module Wheelhouse
  class QuotationDownloadService
    XLSX = "xlsx"
    PDF = "pdf"
    def initialize(quotation_id:, tender_ids:, format:, scope: {})
      @quotation_id = quotation_id
      @tender_ids = tender_ids
      @format = format
      @scope = scope
    end

    def document
      case format
      when XLSX
        xlsx_download
      when PDF
        pdf_download
      else
        raise ApplicationError::MissingDownloadFormat
      end
    end

    private

    attr_reader :quotation_id, :tender_ids, :format, :scope

    def pdf_download
      PdfService.new(
        tender_ids: tender_ids,
        quotation_id: quotation_id
      ).download
    end

    def xlsx_download
      ExcelWriterService.new(
        tender_ids: tender_ids,
        quotation_id: quotation_id,
        scope: scope
      ).quotation_sheet
    end
  end
end
