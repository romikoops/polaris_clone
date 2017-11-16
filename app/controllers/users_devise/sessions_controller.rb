class UsersDevise::SessionsController < DeviseTokenAuth::SessionsController
  # before_filter :configure_sign_in_params, only: [:create]
  wrap_parameters false
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    reset_session
    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :session
  #   params.permit!
  # end
end
