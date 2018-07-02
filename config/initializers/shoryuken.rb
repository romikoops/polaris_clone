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
# Shoryuken.configure_client do |config|
#  if Rails.env == 'development'
#     Shoryuken.sqs_client = Aws::SQS::Client.new(access_key_id: ENV['AWS_KEY'], secret_access_key: ENV['AWS_SECRET'], region: 'eu-central-1', endpoint: 'http://127.0.0.1:4576/',
#     verify_checksums: false)
#   else
#     Shoryuken.sqs_client = Aws::SQS::Client.new(access_key_id: ENV['AWS_KEY'], secret_access_key: ENV['AWS_SECRET'], region: 'eu-central-1')
#   end
# end
Shoryuken.configure_server do |config|
  # Replace Rails logger so messages are logged wherever Shoryuken is logging
  # Note: this entire block is only run by the processor, so we don't overwrite
  #       the logger when the app is running as usual.
  # if Rails.env == 'development'
  #   Shoryuken.sqs_client = Aws::SQS::Client.new(access_key_id: ENV['AWS_KEY'], secret_access_key: ENV['AWS_SECRET'], region: 'eu-central-1', endpoint: 'http://127.0.0.1:4576/',
  #   verify_checksums: false)
  # else
  #   Shoryuken.sqs_client = Aws::SQS::Client.new(access_key_id: ENV['AWS_KEY'], secret_access_key: ENV['AWS_SECRET'], region: 'eu-central-1')
  # end
  Shoryuken.sqs_client = Aws::SQS::Client.new(access_key_id: ENV['AWS_KEY'], secret_access_key: ENV['AWS_SECRET'], region: 'eu-central-1')
  Rails.logger = Shoryuken::Logging.logger
  Rails.logger.level = Logger::INFO
  config.server_middleware do |chain|
    chain.add Shoryuken::Middleware::Server::RavenReporter
  end

  # For dynamically adding queues prefixed by Rails.env
  # %w(queue1 queue2).each do |name|
  #   Shoryuken.add_queue("#{Rails.env}_#{name}", 1)
  # end
end
