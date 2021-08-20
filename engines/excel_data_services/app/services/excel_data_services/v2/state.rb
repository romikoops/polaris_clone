# frozen_string_literal: true

module ExcelDataServices
  module V2
    class State
      # The State object gets passed along throughout the entire pipeline, carrying data and error information from step to step. It also holds the overrides provided to the uploader class for use in the different Sections
      attr_reader :xlsx, :section, :overrides

      def initialize(xlsx:, section:, overrides:)
        @xlsx = xlsx
        @section = section
        @overrides = overrides
        @frame = Rover::DataFrame.new
        @errors = []
        @stats = []
      end

      attr_accessor :insertable_data, :stats, :errors, :frame

      def email_result
        stats.group_by(&:type).inject({ errors: errors }) do |result, (type, stats)|
          result.merge(type.to_sym => { created: stats.sum(&:created), failed: stats.sum(&:failed) })
        end
      end

      def [](key)
        send(key)
      end

      def failed?
        errors.present?
      end

      delegate :group_id, to: :overrides

      def organization_id
        Organizations.current_id
      end

      def organization
        @organization ||= Organizations::Organization.find(organization_id)
      end
    end
  end
end
