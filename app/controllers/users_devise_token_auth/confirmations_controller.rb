# frozen_string_literal: true

module UsersDeviseTokenAuth
  class UsersDeviseTokenAuth::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
    skip_before_action :require_authentication!
    skip_before_action :require_non_guest_authentication!

    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      raise ApplicationError::IncorrectToken if resource.errors.present?

      response_handler(resource)
    end
  end
end
