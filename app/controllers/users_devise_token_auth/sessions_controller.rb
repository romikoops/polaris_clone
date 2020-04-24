# frozen_string_literal: true

module UsersDeviseTokenAuth
  class UsersDeviseTokenAuth::SessionsController < DeviseTokenAuth::SessionsController
    before_action :configure_permitted_parameters, if: :devise_controller?
    skip_before_action :require_authentication!
    skip_before_action :require_non_guest_authentication!

    wrap_parameters false

    def render_create_error_bad_credentials
      raise ApplicationError::BadCredentials
    end

    private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: [:tenant_id])
    end

    def find_resource(_, email)
      query = "
        tenant_id = ?
        AND email = ?
        AND provider = 'tenant_email'
      "

      @resource = resource_class.where(query, params[:tenant_id], email).first
    end

    def render_create_success
      render json: {
        data: ProfileTools.merge_profile(
          target: @resource.token_validation_response
        ).merge(inactivityLimit: inactivity_limit)
      }
    end
  end
end
