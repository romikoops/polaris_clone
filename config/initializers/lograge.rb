# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.base_controller_class = ['ActionController::API', 'ActionController::Base']

  config.lograge.ignore_actions = ['Easymon::ChecksController#index']

  config.lograge.custom_options = lambda do |event|
    exceptions = %w(controller action format id)
    {
      host: event.payload[:host],
      tenant: event.payload[:tenant],
      user_id: event.payload[:user_id],
      params: event.payload[:params].except(*exceptions)
    }
  end

  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host
    }
  end
end
