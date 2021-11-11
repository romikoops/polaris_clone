# frozen_string_literal: true

module Notifications
  class AdminMailer < ApplicationMailer
    default from: "support@itsmycargo.com"

    before_action do
      Organizations.current_id = current_organization.id
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
      @user = @query.client || Users::Client.new(profile:  Users::ClientProfile.new)
      @profile = @user.profile
      @results = @offer.results.map { |result| Notifications::ResultDecorator.new(result, context: { scope: current_scope(user: @user) }) }
      attachments[@offer.file.filename.to_s] = @offer.attachment if @offer.file.attached?

      mail to: params[:recipient], subject: subject_line(results: @offer.results, noun: "Quotation")
    end

    def shipment_request_created
      @shipment_request = params[:shipment_request]
      @user = @shipment_request.client
      @query = @shipment_request.result.query
      @profile = @user.profile
      @result = Notifications::ResultDecorator.new(@shipment_request.result, context: { scope: current_scope(user: @user) })
      attachments[@shipment_request.file.filename.to_s] = @shipment_request.file_binary if @shipment_request.file.attached?
      mail to: params[:recipient], subject: subject_line(results: [@shipment_request.result], noun: "Booking")
    end

    protected

    def company
      "ItsMyCargo ApS"
    end

    def subject_line(results:, noun:)
      text = Notifications::SubjectLine.new(
        results: results, scope: current_scope(user: @user), noun: noun
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
