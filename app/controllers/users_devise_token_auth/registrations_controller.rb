# frozen_string_literal: true

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
          address = Address.create_from_raw_params!(address_params)
          address.geocode_from_address_fields!
          resource.addresses << address unless address.nil?
        end

        @headers = resource.create_new_auth_token
      end
    end

    def render_create_success
      @headers.each do |k, v|
        response.headers[k] = v
      end

      render json: {
        status: 'success',
        data:   @resource.token_validation_response
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

      params_h[:vat_number] = params_h.delete(:VAT_number) unless params_h[:VAT_number].nil?

      unless params_h[:cookies].nil?
        params_h.delete(:cookies)
        params_h[:optin_status_id] = OptinStatus.find_by(tenant: !params[:guest], itsmycargo: !params[:guest], cookies: true).id
      end

      ActionController::Parameters.new(params_h).permit(*User::PERMITTED_PARAMS)
    end

    def provider
      'tenant_email'
    end

    def address_params
      params.require(:address).permit(
        :street, :street_number, :zip_code, :city, :country
      )
    end
  end
end
