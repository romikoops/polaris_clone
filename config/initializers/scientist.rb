module Scientist
  class ResultPublisher
    PERCENT_SEND_EMAIL = 100

    def initialize(experiment_name:, info_extractor:)
      @experiment_name = experiment_name
      @info_extractor = info_extractor
    end

    def perform
      store_mismatched_data unless info_extractor.valid?
      schedule_email_job if send_email?
    end

    private

    attr_reader :experiment_name, :info_extractor

    def store_mismatched_data
      key = "science:#{experiment_name}:mismatch"

      redis_pool.with do |redis|
        redis.lpush(key, { Time.now.to_i => info_extractor.payload }.to_json)
        redis.ltrim(key, 0, 1000)
        redis.expire(key, 1.month.to_i)
      end
    end

    def redis_pool
      @redis_pool ||= ConnectionPool.new { Redis.new }
    end

    def send_email?
      rand(100) < PERCENT_SEND_EMAIL
    end

    def schedule_email_job
      ScientistMailer
        .with(**info_extractor.mailer_params)
        .complete_email
        .deliver_later
    end
  end

  class PhoenixExperiment
    include Scientist::Experiment

    PERCENT_ENABLED = 100

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def enabled?
      rand(100) < PERCENT_ENABLED
    end

    def publish(result)
      info_extractor = PhoenixResultExtractor.new(result: result)
      ResultPublisher.new(experiment_name: name, info_extractor: info_extractor).perform
    end

    class PhoenixResultExtractor
      def initialize(result:)
        @result = result
      end

      def valid?
        result.matched?
      end

      def payload
        @payload ||= {
          name: experiment_name,
          context: result.context,
          control: extracted_value(observation: control),
          candidate: extracted_value(observation: candidate),
          execution_order: result.observations.map(&:name)
        }
      end

      def mailer_params
        {
          experiment_name: experiment_name,
          app_name: app_name,
          has_errors: result.mismatched?,
          query_input_params: query_input_params,
          control_value: control_value,
          candidate_value: candidate_value
        }.as_json.deep_symbolize_keys
      end

      private

      attr_reader :result

      def experiment_name
        @experiment_name ||= result.experiment_name
      end

      def control
        @control ||= result.control
      end

      def candidate
        @candidate ||= result.candidates.first
      end

      def control_value
        @control_value ||= control.cleaned_value.merge(duration: result.control.duration)
      end

      def candidate_value
        @candidate_value ||= (candidate.cleaned_value || {}).merge(duration: candidate.duration)
      end

      def request
        @request ||= result.context[:request]
      end

      def query
        @query ||= request.query
      end

      def query_input_params
        request.params
      end

      def app_name
        Doorkeeper::Application.find_by(id: query.source_id).name
      end

      def extracted_value(observation:)
        if observation.raised?
          {
            exception: observation.exception.class,
            message: observation.exception.message,
            backtrace: observation.exception.backtrace
          }
        else
          {
            value: observation.value,
            cleaned_value: observation.cleaned_value
          }
        end
      end
    end
  end
end
