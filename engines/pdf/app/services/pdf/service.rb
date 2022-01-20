# frozen_string_literal: true

require "active_storage"
module Pdf
  class Service < Pdf::Base
    attr_reader :organization, :user, :url

    def file
      @file ||= begin
        offer.file.attach(file_arguments)
        offer
      end
    end

    delegate :attachment, to: :file

    def decorated_query
      @decorated_query = ResultFormatter::QueryDecorator.decorate(query, context: {scope: scope})
    end

    def decorated_company
      ResultFormatter::CompanyDecorator.decorate(decorated_query.company, context: {client: query.client})
    end

    def decorated_results
      @decorated_results ||= ResultFormatter::ResultDecorator.decorate_collection(offer.results, context: {scope: scope})
    end

    def logo
      @logo ||= Base64.encode64(@theme.large_logo.download) if @theme.large_logo.attached?
    end

    def pdf
      @pdf ||= begin
        pdf_html = ActionController::Base.new.render_to_string(
          layout: "pdfs/simple.pdf.html.erb",
          template: template,
          locals: locals_for_generation
        )
        pdf = PDFKit.new(pdf_html)
        pdf.to_pdf
      end
    end

    def locals_for_generation
      {
        query: decorated_query,
        results: decorated_results,
        company: decorated_company,
        address: decorated_company.object.present? ? decorated_company.address : nil,
        logo: logo,
        organization: organization,
        theme: theme,
        scope: scope
      }
    end

    private

    def file_arguments
      {
        io: StringIO.new(pdf),
        filename: "#{file_text}.pdf",
        content_type: "application/pdf"
      }
    end
  end
end
