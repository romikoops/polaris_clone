module UsersDeviseTokenAuth
  class UsersDeviseTokenAuth::SessionsController < DeviseTokenAuth::SessionsController
    skip_before_action :require_authentication!
    skip_before_action :require_non_guest_authentication!
    
    wrap_parameters false
    # def render_create_success
    #   render json: {data: @resource.errors}
    # end
    def create
      # byebug
      super
    end
    def render_create_error_not_confirmed
      byebug
    end
    def render_create_error_bad_credentials
      byebug
    end
  end
end