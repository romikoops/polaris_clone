module UsersDeviseTokenAuth
	class UsersDeviseTokenAuth::RegistrationsController < DeviseTokenAuth::RegistrationsController
	  before_action :configure_permitted_parameters, if: :devise_controller?
		skip_before_action :require_authentication!
		skip_before_action :require_non_guest_authentication!
		
		def create
			if sign_up_params[:guest]
				# 
			end
			super
		end

		protected

		def configure_permitted_parameters
		  devise_parameter_sanitizer.permit(:sign_up, keys: [:guest, :tenant_id, :first_name, :last_name])
		end
	end
end