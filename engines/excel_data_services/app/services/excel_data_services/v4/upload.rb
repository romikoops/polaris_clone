# frozen_string_literal: true

# The Schemas::Sheet class defines the interaction with the specific type of sheet in question
module ExcelDataServices
  module V4
    class Upload
      DEFINITION_PATH = Rails.root.join("engines/excel_data_services/app/services/excel_data_services/v4/files/sections")
      # This class receives the uploaded file and attempts to find a valid Sheet config. Once found it will trigger the sheet and send the email with the results/errors
      attr_reader :file, :arguments

      def self.upload(file:, arguments:)
        new(file: file, arguments: arguments).perform
      end

      def initialize(file:, arguments:)
        @file = file
        @arguments = arguments
      end

      def perform
        stats.group_by(&:type).inject({ errors: errors }) do |result, (type, stats)|
          result.merge(type.to_sym => { created: stats.sum(&:created), failed: stats.sum(&:failed) })
        end
      end

      def valid?
        sheet.present?
      end

      def sheet
        @sheet ||= sheets.find(&:valid?)
      end

      def sheets
        @sheets ||= filtered_schema_types.map do |schema_type|
          ExcelDataServices::V4::Files::Section.new(
            state: ExcelDataServices::V4::State.new(
              file: file,
              section: schema_type,
              overrides: Overrides.new(
                group_id: arguments[:group_id],
                hub_id: arguments[:hub_id],
                distribute: arguments[:distribute]
              )
            )
          )
        end
      end

      def filtered_schema_types
        available_schema_types - arguments.fetch(:disabled_uploaders, []).map(&:underscore)
      end

      def available_schema_types
        @available_schema_types ||= Dir[[DEFINITION_PATH, "*.yml"].join("/")].map { |path| File.basename(path, ".yml") }
      end

      def result_state
        @result_state ||= sheet.perform
      end

      delegate :errors, :stats, to: :result_state
    end
  end
end
