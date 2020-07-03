# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def create
    @user = Authentication::User.authentication_scope.find_by(email: params[:email])

    if @user
      @user.deliver_reset_password_instructions!
      response_handler(@user)
    else
      head :not_found
    end
  end

  # This is the reset password form.
  def edit
    @token = params[:id]
    @redirect_url = params[:redirect_url]
    @user = Authentication::User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

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
    render json: {success: false}, status: 401
  end
end
