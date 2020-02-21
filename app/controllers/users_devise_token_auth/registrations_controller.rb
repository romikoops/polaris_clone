# frozen_string_literal: true

module UsersDeviseTokenAuth
  class UsersDeviseTokenAuth::RegistrationsController < DeviseTokenAuth::RegistrationsController
    before_action :configure_permitted_parameters, if: :devise_controller?
    skip_before_action :require_authentication!
    skip_before_action :require_non_guest_authentication!

    def create
      super do |resource|
        # Create UserProfile

        create_params = @profile_params
                        .slice('first_name', 'last_name', 'phone', 'company_name')
                        .merge(user_id: ::Tenants::User.find_by(legacy_id: resource.id).id)
        profile = Profiles::Profile.create(create_params)

        # Create token even though email is not confirmed
        resource.create_token

        if quotation_tool?(resource)
          resource.role_id = Role.find_by_name('agency_manager').id
          @agency = Agency.find_or_create_by!(
            name: profile.company_name,
            tenant_id: resource.tenant.id
          )

          resource.agency_id = @agency.id
        else
          resource.role_id = Role.find_by_name('shipper').id
        end

        resource.save!

        @headers = resource.create_new_auth_token
      end
    end

    def quotation_tool?(resource)
      scope = ::Tenants::ScopeService.new(target: ::Tenants::User.find_by(legacy_id: resource.id)).fetch
      @quotation_tool ||= scope.values_at('closed_quotation_tool', 'open_quotation_tool').all?
    end

    def render_create_success
      @headers.each do |k, v|
        response.headers[k] = v
      end

      render json: {
        status: 'success',
        data: @resource.token_validation_response
      }
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
      params_h[:password_confirmation] = params_h.delete(:confirm_password) unless params_h[:confirm_password].nil?

      unless params_h[:cookies].nil?
        params_h.delete(:cookies)
        params_h[:optin_status_id] = OptinStatus.find_by(
          tenant: !params[:guest],
          itsmycargo: !params[:guest],
          cookies: true
        ).id
      end

      @profile_params = params_h.slice(
        *(params_h.keys - %w[email password password_confirmation guest tenant_id])
      )

      ActionController::Parameters.new(
        params_h.slice('email', 'password', 'password_confirmation', 'guest', 'tenant_id')
      ).permit(*User::PERMITTED_PARAMS)
    end

    def provider
      'tenant_email'
    end
  end
end
