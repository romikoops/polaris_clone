class UploadMailer < ApplicationMailer
  default from: "notifications@itsmycargo.shop"
  layout "notification"

  def complete_email
    @user = Users::User.find(params[:user_id])
    @organization = params[:organization]
    @result = params[:result]
    @result["errors"] ||= []
    @file = params[:file]
    @notification_type = @result.fetch("errors", []).empty? ? "good" : "bad"
    @has_errors = @result["errors"].present?

    verdict = @has_errors ? "with errors" : "successfully"
    @notification_title = "Upload of #{@file} for #{@organization.slug} completed #{verdict}."

    mail(to: @user.email, subject: "[#{@organization.slug}] #{@file} uploaded #{verdict}")
  end
end
