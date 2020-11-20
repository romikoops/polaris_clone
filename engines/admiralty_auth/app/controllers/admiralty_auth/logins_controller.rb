# frozen_string_literal: true

require_dependency "admiralty_auth/application_controller"

module AdmiraltyAuth
  class LoginsController < ApplicationController
    def new
    end

    def create
      if authenticate_with_google
        session[:last_activity_at] = Time.zone.now
        redirect_to session[:return_to_url] || admiralty.root_url
      else
        redirect_to admiralty_auth.login_url, alert: "authentication_failed"
      end
    end

    def destroy
      session[:last_activity_at] = nil
      redirect_to admiralty_auth.login_url
    end

    private

    def authenticate_with_google
      return false if flash[:google_sign_in_token].blank?

      %w[itsmycargo.com].include?(google_identity.hosted_domain)
    end

    def google_identity
      @google_identity ||= GoogleSignIn::Identity.new(flash[:google_sign_in_token])
    end
  end
end
