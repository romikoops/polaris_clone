# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Base
          attr_reader :state, :section

          def initialize(section:, state:)
            @section = section
            @state = state
            parse_config
          end

          delegate :xlsx, :organization, to: :state
          delegate :sheets, to: :xlsx
          delegate :scope, to: :organization

          private

          def parse_config
            sorted_dependencies.each do |dependency_action|
              ExcelDataServices::V4::Files::Parsers::Schema.new(
                path: "section_data", section: dependency_action, pattern: self.class::SPLIT_PATTERN
              ).perform do |schema_lines|
                instance_eval(schema_lines)
              end
            end
          end

          def sorted_dependencies
            PrerequisiteExtractor.new(parent: section).dependencies
          end

          def non_empty_sheets
            @non_empty_sheets ||= xlsx.sheets.select { |all_sheet_name| xlsx.sheet(all_sheet_name).first_column }
          end
        end
      end
    end
  end
end
