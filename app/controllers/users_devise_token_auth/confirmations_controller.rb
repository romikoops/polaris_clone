module UsersDeviseTokenAuth
	class UsersDeviseTokenAuth::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
		skip_before_action :require_authentication!
		skip_before_action :require_non_guest_authentication!
	end
end
