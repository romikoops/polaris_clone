# frozen_string_literal: true

module UsersDeviseTokenAuth
  class UsersDeviseTokenAuth::PasswordsController < DeviseTokenAuth::PasswordsController
    skip_before_action :require_authentication!
    skip_before_action :require_non_guest_authentication!
    before_action :set_user_by_token, only: :update

    def update
      # This action is mostly a direct copy of the devise_token_auth v0.1.43.beta1 source
      # Monkey-patches are marked with ## (!) ##

      # make sure user is authorized
      return render_update_error_unauthorized unless @resource

      # make sure account doesn't use oauth2 provider
      return render_update_error_password_not_required unless @resource.provider == "tenant_email" ## (!) ##

      # ensure that password params were sent
      unless password_resource_params[:password] && password_resource_params[:password_confirmation]
        return render_update_error_missing_password
      end

      if @resource.send(resource_update_method, password_resource_params)
        @resource.allow_password_change = false if recoverable_enabled?
        @resource.save!

        return render_update_success
      else
        return render_update_error
      end
    end

    def find_resource(_, email)
      tenant_id = params[:tenant_id]
      query = "
        tenant_id = ?
        AND email = ?
        AND provider = 'tenant_email'
      "

      @resource = resource_class.where(query, tenant_id, email).first
    end
  end
end
