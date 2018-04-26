module UsersDeviseTokenAuth
	class UsersDeviseTokenAuth::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
			skip_before_action :require_authentication!
			skip_before_action :require_non_guest_authentication!

		def show
			super do |resource|
				# byebug
			end
		end

		private

		def after_confirmation_path_for(resource_name, resource)
		  super
		end
	end
end
