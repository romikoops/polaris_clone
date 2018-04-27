module UsersDeviseTokenAuth
	class UsersDeviseTokenAuth::RegistrationsController < DeviseTokenAuth::RegistrationsController
	  before_action :configure_permitted_parameters, if: :devise_controller?
		skip_before_action :require_authentication!
		skip_before_action :require_non_guest_authentication!
		
		def create
			super do |resource|
				# Create token even though email is not confirmed
				resource.create_token
				resource.save!

				# Create Address for non-guest Users
				unless resource.guest
					location = Location.create(location_params)
					location.geocode_from_address_fields!
					resource.locations << location unless location.nil?
				end

				@headers_to_append = resource.create_new_auth_token
			end
		end

		def render_create_success
			@headers_to_append.each do |k, v|
				response.headers[k] = v
			end

			super
		end

		protected

		def configure_permitted_parameters
		  devise_parameter_sanitizer.permit(
		  	:sign_up,
		  	keys: User::PERMITTED_PARAMS
		  )
		end

		def sign_up_params
			params_h = super.to_h
			
			unless params_h[:confirm_password].nil?
				params_h[:password_confirmation] = params_h.delete(:confirm_password)
			end

			unless params_h[:VAT_number].nil?
				params_h[:vat_number] = params_h.delete(:VAT_number)
			end
			ActionController::Parameters.new(params_h).permit(*User::PERMITTED_PARAMS)
		end

		def provider
			"tenant_email"
		end

		def location_params
			params.require(:location).permit(
		  	:street, :street_number, :zip_code, :city, :country
			)
		end
	end
end