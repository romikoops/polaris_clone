module UsersDeviseTokenAuth
	class RegistrationsController < DeviseTokenAuth::RegistrationsController
	  before_action :configure_permitted_parameters, if: :devise_controller?
		
		def create
			if sign_up_params[:guest]
				# byebug
			end
			super
		end

		protected

		def configure_permitted_parameters
		  devise_parameter_sanitizer.permit(:sign_up, keys: [:guest, :tenant_id, :first_name, :last_name])
		end
	end
end