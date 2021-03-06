# frozen_string_literal: true

# The Schemas::Sheet class defines the interaction with the specific type of sheet in question
module ExcelDataServices
  module V3
    class Upload
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
        stats.group_by(&:type).inject({ errors: errors, exception: exception_raised? }) do |result, (type, stats)|
          result.merge(type.to_sym => { created: stats.sum(&:created), failed: stats.sum(&:failed) })
        end
      end

      def valid?
        not_xml? && sheet.present?
      end

      def sheet
        @sheet ||= schema_types.map { |schem_type| ExcelDataServices::V3::Files::SheetType.new(file: file, type: schem_type, arguments: arguments) }.find(&:valid?)
      end

      def schema_types
        %w[SacoPricings Pricings Schedules LocalCharges Hubs Clients Truckings] - arguments.fetch(:disabled_uploaders, [])
      end

      def result_state
        @result_state ||= sheet.perform
      end

      def exception_raised?
        stats.any?(&:exception)
      end

      delegate :errors, :stats, to: :result_state

      def not_xml?
        ExcelDataServices::V4::State::XML_CONTENT_TYPES.exclude?(file.file.content_type)
      end
    end
  end
end
