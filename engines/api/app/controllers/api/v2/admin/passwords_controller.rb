# frozen_string_literal: true

module Api
  module V2
    module Admin
      class PasswordsController < ApiController
        skip_before_action :doorkeeper_authorize!
        skip_before_action :ensure_organization!
        before_action :validate_referrer!, only: [:create]

        def create
          user = Users::User.find_by(email: params[:email])
          render json: { error_code: "user_not_available", success: false }, status: :unauthorized and return if user.blank?

          render json: { error_code: "sso_user_not_supported", success: false }, status: :unauthorized and return if user.crypted_password.nil?

          user.generate_reset_password_token!
          Notifications::UserMailer.with(
            domain: referrer_host,
            user: user
          ).reset_password_email.deliver_later

          render json: { success: true }
        end

        # This action fires when the user has sent the reset password form.
        def update
          render json: { success: false }, status: :unauthorized and return if user.blank?

          render json: { error_code: "password_mismatch" }, status: :unprocessable_entity and return if params.require(:password) != params.require(:password_confirmation)

          render json: { error_code: "weak_password" }, status: :unprocessable_entity and return if password_checker.is_weak?(params[:password])

          render json: { success: true } if user.change_password!(params[:password])
        end

        private

        def user
          @user ||= Users::User.load_from_reset_password_token(params[:id])
        end

        # Creates and returns an instance of StrongPassword Strength checker which restricts password to be atleast 6 chars long
        # use_dictionary indicates that common potential passwords are now allowed ex: "qwerty", "123456" etc
        # min_entropy 12 approximately support password with atleast 1 Capital, 1 Numeric and minimum 6 chars.
        # More about entropy values http://cubicspot.blogspot.com/2011/11/how-to-calculate-password-strength.html

        def password_checker
          @password_checker ||= StrongPassword::StrengthChecker.new(use_dictionary: false, min_word_length: 8, min_entropy: 12)
        end
      end
    end
  end
end
