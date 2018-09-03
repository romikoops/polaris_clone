# frozen_string_literal: true

module Shoryuken
  module Middleware
    module Server
      class RavenReporter
        def call(_worker_instance, queue, _sqs_msg, body)
          tags = { job: body['job_class'], queue: queue }
          context = { message: body }
          Raven.capture(tags: tags, extra: context) do
            yield
          end
        end
      end
    end
  end
end

Shoryuken.configure_server do |config|
  Shoryuken.sqs_client = Aws::SQS::Client.new(
    access_key_id: Settings.aws.access_key_id,
    secret_access_key: Settings.aws.secret_access_key,
    region: 'eu-central-1'
  )
  Rails.logger = Shoryuken::Logging.logger
  Rails.logger.level = Logger::INFO
  config.server_middleware do |chain|
    chain.add Shoryuken::Middleware::Server::RavenReporter
  end
end
