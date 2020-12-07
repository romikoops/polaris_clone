module Notifications
  class AdminMailer < ApplicationMailer
    default from: "support@itsmycargo.com"

    before_action do
      attachments.inline["logo.png"] = Pathname.new(
        File.expand_path("../../assets/images/notifications/logo-blue.png", __dir__)
      ).read
    end

    def user_created
      @user = params[:user]
      @profile = params[:profile]

      mail to: params[:recipient]
    end

    protected

    def company
      "ItsMyCargo ApS"
    end
  end
end
