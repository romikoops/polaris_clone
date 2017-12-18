module UsersDeviseTokenAuth
  class SessionsController < DeviseTokenAuth::SessionsController
    wrap_parameters false
    # def render_create_success
    #   render json: {data: @resource.errors}
    # end
    # def create
    #   # reset_session
    #   super
    # end
    def render_create_error_not_confirmed
      byebug
    end
    def render_create_error_bad_credentials
      byebug
    end
  end
end