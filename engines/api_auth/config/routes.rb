# frozen_string_literal: true

ApiAuth::Engine.routes.draw do
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
    controllers tokens: :tokens, token_info: :token_info
  end

  delete "oauth/signout", to: "auth#destroy"
end
