# frozen_string_literal: true

require_dependency 'admiralty_auth/application_controller'

module AdmiraltyAuth
  class AuthorizedController < ApplicationController
    before_action :authenticate!

    def authenticated?
      session.key?(:last_activity_at) && session[:last_activity_at] >= 1.hour.ago
    end

    def authenticate!
      if authenticated?
        session[:last_activity_at] = Time.zone.now
        return
      end

      session[:return_to_url] = request.url
      redirect_to(admiralty_auth.login_path, flash: { return_to_url: request.url })
    end
  end
end
