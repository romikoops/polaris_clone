# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def create
    @user = Authentication::User.authentication_scope.find_by(email: params[:email])

    if @user
      @user.organization_id = params[:organization_id] if @user.organization_id.blank?
      @user.generate_reset_password_token!
      Notifications::UserMailer.with(
        organization: ::Organizations::Organization.find(@user.organization_id),
        user: @user,
        profile: Profiles::Profile.find_by(user: @user)
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
    @user = Authentication::User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:password_confirmation]
    # the next line clears the temporary token and updates the password

    if @user.change_password!(params[:password])
      render json: {success: true}
    end
  end

  private

  def not_authenticated
    render json: {success: false}, status: :unauthorized
  end
end
