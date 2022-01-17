# frozen_string_literal: true

module ExcelDataServices
  module V3
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
        import_result
        stats
      rescue ActiveRecord::StatementInvalid => e
        Sentry.capture(e)
        ExcelDataServices::V3::Stats.new(
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

      def import_result
        @import_result ||= model.import(
          model_data,
          default_options.merge(options)
        )
      end

      def model_data
        ModelInitializer.new(model: model, data: data).perform
      end

      def stats
        ExcelDataServices::V3::Stats.new(
          type: type,
          created: import_result.ids.count,
          failed: import_result.failed_instances.count,
          errors: import_errors
        )
      end

      def import_errors
        import_result.failed_instances.map do |failed|
          {
            sheet_name: type,
            reason: failed.errors.to_a.join(", ")
          }
        end
      end

      def default_options
        { batch_size: BATCH_SIZE, on_duplicate_key_ignore: true }
      end
    end
  end
end
