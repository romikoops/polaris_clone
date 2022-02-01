# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  skip_before_action :doorkeeper_authorize!
  before_action :validate_referrer!, only: [:create]

  def create
    render json: { error_code: "organization_mismatch", success: false }, status: :unauthorized and return if organization_mismatch?

    @user = Users::Client.find_by(email: params[:email]) || Users::User.find_by(email: params[:email])

    if @user
      @user.generate_reset_password_token!
      mailer_class = @user.is_a?(Users::User) ? Notifications::UserMailer : Notifications::ClientMailer
      mailer_class.with(
        domain: referrer_host,
        organization: current_organization,
        user: @user
      ).reset_password_email.deliver_later

      response_handler(@user)
    else
      head :not_found
    end
  end

  # This is the reset password form.
  def edit
    @token = params[:id]
    @redirect_url = params[:redirect_url]

    redirect_to("#{@redirect_url}?reset_password_token=#{@token}")
  end

  # This action fires when the user has sent the reset password form.
  def update
    @token = params[:id]
    @user = Users::Client.load_from_reset_password_token(params[:id]) || Users::User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    render json: { success: false }, status: :unprocessable_entity if params[:password] != params[:password_confirmation]

    render json: { success: true } if @user.change_password!(params[:password])
  end

  private

  def organization_mismatch?
    return false unless organization_domain.organization.id != current_organization.id

    true
  end

  def not_authenticated
    render json: { success: false }, status: :unauthorized
  end
end
