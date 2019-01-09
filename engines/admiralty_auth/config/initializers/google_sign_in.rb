# frozen_string_literal: true

Rails.application.configure do
  if Settings.google_sign_in
    config.google_sign_in.client_id     = Settings.google_sign_in.client_id
    config.google_sign_in.client_secret = Settings.google_sign_in.client_secret
  end
end
