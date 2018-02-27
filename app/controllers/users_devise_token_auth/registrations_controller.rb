module UsersDeviseTokenAuth
	class UsersDeviseTokenAuth::RegistrationsController < DeviseTokenAuth::RegistrationsController
	  before_action :configure_permitted_parameters, if: :devise_controller?
		skip_before_action :require_authentication!
		skip_before_action :require_non_guest_authentication!
		
		def create
			super
			if @resource.valid? && !@resource.guest
				location = Location.create(location_params)
				@resource.locations << location unless location.nil?
				@resource.save
			end				
		end

		protected

		def configure_permitted_parameters
		  devise_parameter_sanitizer.permit(
		  	:sign_up,
		  	keys: [
		  		:guest, :tenant_id, :confirm_password,
		  		:company_name, :VAT_number, :first_name, :last_name, :phone
		  	]
		  )
		end

		def sign_up_params
			return_params = super.to_h
			
			unless return_params[:confirm_password].nil?
				return_params[:password_confirmation] = return_params.delete(:confirm_password)
			end

			unless return_params[:VAT_number].nil?
				return_params[:vat_number] = return_params.delete(:VAT_number)
			end

			return_params
		end

		def location_params
			params.require(:location).permit(
		  	:street, :street_number, :zip_code, :city, :country
			)
		end
	end
end