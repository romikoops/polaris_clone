# frozen_string_literal: true

module ExcelDataServices
  module V4
    class State
      # The State object gets passed along throughout the entire pipeline, carrying data and error information from step to step. It also holds the overrides provided to the uploader class for use in the different Sections
      attr_reader :file, :section, :overrides

      def initialize(file:, section:, overrides:)
        @file = file
        @section = section
        @overrides = overrides
        @frame = Rover::DataFrame.new
        @errors = []
        @stats = []
      end

      attr_accessor :insertable_data, :stats, :errors, :frame

      def [](key)
        send(key)
      end

      delegate :group_id, :document_id, to: :overrides

      def organization_id
        Organizations.current_id
      end

      def organization
        @organization ||= Organizations::Organization.find(organization_id)
      end

      def file_name
        file.file.filename.to_s
      end

      def spreadsheet
        @spreadsheet ||= ExcelDataServices::V4::Spreadsheet.new(document: file) unless xml?
      end

      def hash_from_xml
        @hash_from_xml ||= ExcelDataServices::V4::Xml.new(document: file) if xml?
      end

      def content_type
        @content_type ||= file.file.content_type
      end

      def xml?
        %w[application/xml application/xhtml+xml].include?(content_type)
      end

      delegate :xlsx, to: :spreadsheet, allow_nil: true
      delegate :xml, to: :hash_from_xml, allow_nil: true
    end
  end
end
