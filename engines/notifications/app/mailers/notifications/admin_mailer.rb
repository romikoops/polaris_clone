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
      @profile = @user.profile

      mail to: params[:recipient]
    end

    def offer_created
      @offer = params[:offer]
      @query = @offer.query
      @user = Users::Client.unscoped.find_by(id: @query.client_id, organization: params[:organization])
      @profile = @user&.profile || Users::ClientProfile.new
      @results = @offer.results.map { |result| Notifications::ResultDecorator.new(result) }
      mail to: params[:recipient], subject: subject_line
    end

    protected

    def company
      "ItsMyCargo ApS"
    end

    def subject_line
      text = Notifications::OfferSubjectLine.new(
        offer: @offer, scope: current_scope(user: @user)
      ).subject_line

      "#{subject_prefix}#{text}"
    end

    def subject_prefix
      if @query.billable?
        ""
      else
        "TEST: "
      end
    end
  end
end
