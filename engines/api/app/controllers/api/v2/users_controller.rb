# frozen_string_literal: true

module Api
  module V2
    class UsersController < ApiController
      skip_before_action :doorkeeper_authorize!
      skip_before_action :ensure_organization!

      def validate
        if user.blank?
          return render(
            json: { error: "User with email #{email} is not registered in our system" },
            status: :not_found
          )
        end
        render json: Api::V2::UserSerializer.new(user_decorator)
      end

      private

      def user_decorator
        @user_decorator ||= Api::V2::UserDecorator.new(user)
      end

      def user
        @user ||= Users::User.find_by(email: email)
      end

      def email
        @email ||= params.require(:email)
      end
    end
  end
end
