# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    class ContentValidator
      attr_reader :source, :section

      delegate :sheet, :schema, to: :source

      def self.valid?(source:, section:)
        new(source: source, section: section).perform
      end

      def initialize(source:, section:)
        @source = source
        @section = section
      end

      def perform
        content_present? && content_unique?
      end

      def content_present?
        (required_content - section_content).empty?
      end

      def content_unique?
        uniqueness_constrained? ? section_content.uniq.length == section_content.length : true
      end

      def required_content
        @required_content ||= schema.dig(section, "content") || []
      end

      def uniqueness_constrained?
        schema.dig(section, "unique")
      end

      def section_content
        section_axis_coordinates(axis: "rows").product(
          section_axis_coordinates(axis: "cols")
        ).map do |target_row, target_col|
          sheet.cell(target_row, target_col)
        end
      end

      def section_axis_coordinates(axis:)
        ExcelDataServices::Schemas::Coordinates::Base.extract(
          source: source, section: section, axis: axis
        )
      end
    end
  end
end
