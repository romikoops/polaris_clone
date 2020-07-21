# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.base_controller_class = ['ActionController::API', 'ActionController::Base']

  config.lograge.ignore_actions = ['Easymon::ChecksController#index']

  config.lograge.custom_options = lambda do |event|
    exceptions = %w(controller action format id)

    options = {}

    options[:host] = event.payload[:host]
    options[:referer] = event.payload[:referer]
    options[:fowarded_host] = event.payload[:fowarded_host]
    options[:params] = event.payload[:params].except(*exceptions)
    options[:search] = event.payload[:searchkick_runtime] if event.payload[:searchkick_runtime].to_f > 0
    options[:organization] = event.payload[:organization]
    options[:user_id] = event.payload[:user_id]

    options
  end

  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      referer: controller.request.referer,
      fowarded_host: controller.request.headers['X-Forwarded-Host']
    }
  end
end
