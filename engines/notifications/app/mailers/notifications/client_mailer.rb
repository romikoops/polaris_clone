# frozen_string_literal: true

module Notifications
  class ClientMailer < UserMailer
    def offer_email
      @offer = params[:offer]
      @query = @offer.query
      @user = @query.client
      @results = @offer.results.map { |result| Notifications::ResultDecorator.new(result) }

      attachments["offer_#{@offer.id}.pdf"] = {
        mime_type: "application/pdf",
        content: @offer.file.blob.download
      }
      mail to: @user.email,
           from: organization_from_email(mode_of_transport: @results.first.mode_of_transport),
           subject: Notifications::OfferSubjectLine.new(offer: @offer, scope: current_scope(user: @user)).subject_line
    end
  end
end
