# frozen_string_literal: true

class UploadMailer < ApplicationMailer
  default from: "notifications@itsmycargo.shop"
  layout "notification"

  def complete_email
    @user = Users::User.find(params[:user_id])
    @result = params[:result] || error_result
    @result["errors"] ||= []
    @file = params[:file]
    @notification_type = @result.fetch("errors", []).empty? ? "good" : "bad"
    @has_errors = @result["errors"].present?
    bcc = params[:bcc] || []
    verdict = @has_errors ? "with errors" : "successfully"
    @notification_title = "Upload of #{@file} completed #{verdict}."

    mail(to: @user.email, bcc: bcc, subject: "[ItsMyCargo] #{@file} uploaded #{verdict}")
  end

  def error_result
    {
      "has_errors" => true,
      "errors" => [
        {
          "sheet_name": @file,
          "reason": "We are sorry, but something has gone wrong while inserting your #{@file} data. The Operations Team has been notified of the error."
        }
      ]
    }
  end
end
