# frozen_string_literal: true

require_dependency 'admiralty_auth/application_controller'

module AdmiraltyAuth
  class AuthorizedController < ApplicationController
    before_action :authenticate_user!

    def current_user
      @current_user ||= if cookies.signed[:admiralty_user_id]
                          if Users::User.exists?(id: cookies.signed[:admiralty_user_id])
                            Users::User.find(cookies.signed[:admiralty_user_id])
                          else
                            cookies.signed[:admiralty_user_id] = nil
                          end
                        end
    end
    helper_method :current_user

    def authenticate_user!
      return if current_user

      session[:return_to_url] = request.url
      redirect_to(admiralty_auth.login_path, flash: { return_to_url: request.url })
    end
  end
end
