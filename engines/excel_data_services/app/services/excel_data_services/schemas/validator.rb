# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    class Validator
      attr_reader :source

      delegate :sheet, :schema, to: :source

      def self.valid?(source:)
        new(source: source).perform
      end

      def initialize(source:)
        @source = source
      end

      def perform
        schema.each do |section, coordinates|
          return false unless section_valid?(section: section)
        end
        true
      end

      def section_valid?(section:)
        return true unless section_required?(section: section)

        conditions = section_conditions(section: section)
        return false if conditions.empty?

        conditions.all?(&:valid?)
      end

      def section_conditions(section:)
        section_axis_targets(section: section, axis: "rows").product(
          section_axis_targets(section: section, axis: "cols")
        ).map do |target_rows, target_cols|
          ExcelDataServices::Schemas::Conditions::Exists.new(sheet: sheet, rows: target_rows, cols: target_cols)
        end
      end

      def section_axis_targets(section:, axis:)
        ExcelDataServices::Schemas::Targets::Base.targets(source: source, section: section, axis: axis)
      end

      def section_required?(section:)
        schema.dig(section, "required")
      end
    end
  end
end
