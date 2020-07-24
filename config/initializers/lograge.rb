# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.base_controller_class = ["ActionController::API", "ActionController::Base"]
  config.lograge.ignore_actions = ["ApplicationController#health", "Easymon::ChecksController#index"]

  config.lograge.custom_options = lambda do |event|
    exceptions = %w[controller action format id]

    options = {time: Time.current.utc}

    options[:host] = event.payload[:host]
    options[:organization] = event.payload[:organization]
    options[:params] = event.payload[:params].except(*exceptions)
    options[:referer] = event.payload[:referer]
    options[:request_id] = event.payload[:request_id]
    options[:search] = event.payload[:searchkick_runtime] if event.payload[:searchkick_runtime].to_f > 0
    options[:user_id] = event.payload[:user_id]

    options
  end

  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      referer: controller.request.referer,
      request_id: controller.request.request_id
    }
  end
end
