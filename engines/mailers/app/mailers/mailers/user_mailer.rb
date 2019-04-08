# frozen_string_literal: true

module Mailers
  class UserMailer < ApplicationMailer
    def activation_needed_email(user)
      @user = user
      mail to: user.email
    end

    def activation_success_email(user)
      @user = user
      mail to: user.email
    end

    def reset_password_email(user)
      @user = user
      mail to: user.email
    end
  end
end
