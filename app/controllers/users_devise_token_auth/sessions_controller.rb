module UsersDeviseTokenAuth
  class UsersDeviseTokenAuth::SessionsController < DeviseTokenAuth::SessionsController
    before_action :configure_permitted_parameters, if: :devise_controller?
    skip_before_action :require_authentication!
    skip_before_action :require_non_guest_authentication!
    
    wrap_parameters false
    # def render_create_success
    #   render json: {data: @resource.errors}
    # end
    def create
      # user request.headers['origin'] to determine tenant
      super
    end
    def render_create_error_not_confirmed
      # 
    end
    def render_create_error_bad_credentials
      raise ApplicationError::BadCredentials
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: [:subdomain_id])
    end   
  end
end