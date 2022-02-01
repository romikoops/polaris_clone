# frozen_string_literal: true

module Notifications
  class DownloadMailer < ApplicationMailer
    default from: "notifications@itsmycargo.shop"

    before_action do
      attachments.inline["logo.png"] = Pathname.new(
        File.expand_path("../../assets/images/notifications/logo-blue.png", __dir__)
      ).read
    end

    def complete_email
      @user = params[:user]
      @organization = params[:organization]
      @result = params[:result]
      @file_name = params[:file_name]
      @category_identifier = params[:category_identifier]
      bcc = params[:bcc] || []
      @document = @result[:document]
      @can_attach = @result[:can_attach].presence

      @has_errors = @result[:errors].present?

      if @document.present?
        @url = Rails.application.routes.url_helpers.rails_blob_url(@document.file) if @document

        if @can_attach
          attachments[@document.text] = {
            mime_type: @document.file.content_type,
            content: @document.attachment
          }
        end
      end
      mail(to: @user.email, bcc: bcc, subject: "[ItsMyCargo] : #{@category_identifier} sheet for download is ready")
    end
  end
end