class UploadMailer < ApplicationMailer
  default from: "notifications@itsmycargo.shop"
  layout "notification"

  def complete_email
    @user = Users::User.find(params[:user_id])
    @result = params[:result]
    @result["errors"] ||= []
    @file = params[:file]
    @notification_type = @result.fetch("errors", []).empty? ? "good" : "bad"
    @has_errors = @result["errors"].present?

    verdict = @has_errors ? "with errors" : "successfully"
    @notification_title = "Upload of #{@file} completed #{verdict}."

    mail(to: @user.email, subject: "[ItsMyCargo] #{@file} uploaded #{verdict}")
  end
end
