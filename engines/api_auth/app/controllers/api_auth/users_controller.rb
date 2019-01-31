# frozen_string_literal: true

require_dependency 'api_auth/application_controller'

module ApiAuth
  class UsersController < ApiController
    skip_before_action :doorkeeper_authorize!, except: %i(show update)
  end
end
