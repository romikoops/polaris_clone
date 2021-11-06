# frozen_string_literal: true

module Notifications
  class ClientMailer < UserMailer
    def offer_email
      @offer = params[:offer]
      @query = @offer.query
      @results = @offer.results.map { |result| Notifications::ResultDecorator.new(result, context: { scope: current_scope(user: @user) }) }

      attachments["offer_#{@offer.id}.pdf"] = {
        mime_type: "application/pdf",
        content: @offer.file.blob.download
      }
      mail to: @user.email,
           from: organization_from_email(mode_of_transport: @results.first.mode_of_transport),
           subject: Notifications::SubjectLine.new(results: @offer.results, scope: current_scope(user: @user), noun: "Quotation").subject_line
    end
  end
end
