module UsersDeviseTokenAuth
	class UsersDeviseTokenAuth::PasswordsController < DeviseTokenAuth::PasswordsController
		skip_before_action :require_authentication!
		skip_before_action :require_non_guest_authentication!
		def create
			# byebug
			super
		end

		def find_resource(_, email)
      tenant_id = Tenant.find_by(subdomain: params[:subdomain_id]).id
      query = "
        tenant_id = ?
        AND email = ?
        AND provider = 'tenant_email'
      "

      @resource = resource_class.where(query, tenant_id, email).first
    end
	

	end
end