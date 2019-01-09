# frozen_string_literal: true

require_dependency 'admiralty_auth/application_controller'

module AdmiraltyAuth
  class LoginsController < ApplicationController
    layout 'admiralty_assets/login'

    def new
    end

    def create
      if (user = authenticate_with_google)
        cookies.signed[:admiralty_user_id] = user.id
        redirect_to session[:return_to_url] || admiralty.root_url
      else
        redirect_to admiralty_auth.login_url, alert: 'authentication_failed'
      end
    end

    private

    def authenticate_with_google
      return unless flash[:google_sign_in_token].present?

      return unless %w(itsmycargo.com).include?(google_identity.hosted_domain)

      user = Users::User.find_or_create_by(google_id: google_identity.user_id)
      user.update(
        email: google_identity.email_address,
        name: google_identity.name,
        google_id: google_identity.user_id
      )

      user
    end

    def google_identity
      @google_identity ||= GoogleSignIn::Identity.new(flash[:google_sign_in_token])
    end
  end
end
