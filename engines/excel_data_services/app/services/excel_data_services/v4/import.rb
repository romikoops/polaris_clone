# frozen_string_literal: true

module ExcelDataServices
  module V4
    class Import
      # This class abstracts the importing of data. It receives the model, data for insertion and any options provided by the config.
      BATCH_SIZE = 2000

      attr_reader :model, :data, :type, :options

      def self.import(model:, data:, type:, options:)
        new(model: model, data: data, type: type, options: options).perform
      end

      def initialize(model:, data:, type:, options: {})
        @model = model
        @data = data
        @type = type
        @options = options
      end

      def perform
        ExcelDataServices::V4::Stats.new(
          type: type,
          created: update_result.ids.count + create_result.ids.count,
          failed: update_result.failed_instances.count + create_result.failed_instances.count,
          errors: import_errors
        )
      rescue ActiveRecord::StatementInvalid => e
        Sentry.capture_exception(e)
        ExcelDataServices::V4::Stats.new(
          type: type,
          created: 0,
          failed: data.length,
          errors: [
            {
              sheet_name: type,
              reason: "We were not able to insert your #{type.humanize} correctly."
            }
          ]
        )
      end

      private

      def model_data
        @model_data ||= ModelInitializer.new(model: model, data: data).perform
      end

      def update_result
        @update_result ||= ImportAction.new(
          model: model,
          data: model_data.select { |datum| datum.id.present? },
          options: options
        )
      end

      def create_result
        @create_result ||= ImportAction.new(
          model: model,
          data: model_data.reject { |datum| datum.id.present? },
          options: options
        )
      end

      def import_errors
        (update_result.failed_instances + create_result.failed_instances).map do |failed|
          {
            sheet_name: type,
            reason: failed.errors.to_a.join(", ")
          }
        end
      end

      def default_options
        { batch_size: BATCH_SIZE, on_duplicate_key_ignore: true }
      end

      class ImportAction
        def initialize(model:, data:, options: {})
          @model = model
          @data = data
          @options = options
        end

        attr_reader :model, :data, :options

        delegate :failed_instances, :ids, to: :import_result

        private

        def import_result
          @import_result ||= model.import(
            data,
            default_options.merge(options)
          )
        end

        def default_options
          { batch_size: BATCH_SIZE, on_duplicate_key_ignore: true }
        end
      end
    end
  end
end
