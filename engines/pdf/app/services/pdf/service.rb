# frozen_string_literal: true

require "active_storage"
module Pdf
  class Service < Pdf::Base
    attr_reader :organization, :user, :url

    def file
      @file ||= existing_document || new_file
    end

    delegate :attachment, to: :file

    def decorated_quotation
      @decorated_quotation = Pdf::QuotationDecorator.decorate(quotation, context: {scope: scope})
    end

    def decorated_company
      Pdf::CompanyDecorator.decorate(decorated_quotation.company)
    end

    def decorated_tenders
      @decorated_tenders ||= Pdf::TenderDecorator.decorate_collection(tenders, context: {scope: scope})
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
        quotation: decorated_quotation,
        tenders: decorated_tenders,
        company: decorated_company,
        address: decorated_company.object.present? ? decorated_company.address : nil,
        logo: logo,
        organization: organization,
        theme: theme,
        scope: scope
      }
    end

    private

    def new_file
      @new_file ||= begin
        args = file_arguments.merge(file_target)
        Legacy::File.create!(args)
      end
    end

    def file_arguments
      {
        text: file_text,
        doc_type: doc_type,
        user: user,
        organization: organization,
        file: {
          io: StringIO.new(pdf),
          filename: "#{file_text}.pdf",
          content_type: "application/pdf"
        }
      }
    end
  end
end
