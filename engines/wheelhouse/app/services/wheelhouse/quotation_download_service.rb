# frozen_string_literal: true

module Wheelhouse
  class QuotationDownloadService
    XLSX = "xlsx"
    PDF = "pdf"
    def initialize(result_ids:, format:, scope: {})
      @results = Journey::Result.where(id: result_ids)
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

    attr_reader :results, :format, :scope

    def offer
      @offer ||= Wheelhouse::OfferBuilder.offer(results: results)
    end

    def pdf_download
      offer
    end

    def query
      @query ||= results.first.query
    end

    def xlsx_download
      ExcelWriterService.new(
        offer: offer,
        scope: scope
      ).quotation_sheet
    end
  end
end
