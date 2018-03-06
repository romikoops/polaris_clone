require "#{Rails.root}/lib/devise_token_auth/app/controllers/devise_token_auth/sessions_controller"

module UsersDeviseTokenAuth
  class UsersDeviseTokenAuth::SessionsController < DeviseTokenAuth::SessionsController
    include UsersDeviseTokenAuth::Concerns::ResourceFinder
    before_action :configure_permitted_parameters, if: :devise_controller?
    skip_before_action :require_authentication!
    skip_before_action :require_non_guest_authentication!
    
    wrap_parameters false

    def render_create_error_bad_credentials
      raise ApplicationError::BadCredentials
    end

    private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: [:subdomain_id])
    end

    def find_resource(field, value)
      tenant = Tenant.find_by(subdomain: params[:subdomain_id])
      query = "
        #{field.to_s} = ?
        AND provider = '#{provider.to_s}'
        AND tenant_id = '#{tenant.id}'
      "

      @resource = resource_class.where(query, value).first
    end
  end
end