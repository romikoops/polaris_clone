# frozen_string_literal: true

ApiAuth::Engine.routes.draw do
  use_doorkeeper
  # use_doorkeeper do
  #   skip_controllers :authorizations, :applications, :authorized_applications
  #   controllers tokens: :tokens, token_info: :token_info
  # end

  delete 'oauth/signout', action: 'auth#destroy'

  resource :me, controller: :users do
    collection do
      get 'reset_password/request', action: 'users#request_reset_password'
      get 'reset_password/:code', action: 'users#reset_password'
    end
  end
end
