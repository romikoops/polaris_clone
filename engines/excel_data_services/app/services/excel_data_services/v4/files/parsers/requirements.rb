# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Requirements < ExcelDataServices::V4::Files::Parsers::Base
          KEYS = %i[required].freeze
          XmlRequirement = Struct.new(:content, :path, keyword_init: true) do
            def valid?
              content.present? && content.key?(*path)
            end
          end

          def requirements
            schema_data[:required].flat_map do |requirement_schema|
              RequirementsBuilder.new(
                requirement_schema: requirement_schema,
                fallback_sheets: non_empty_sheets,
                state: state
              ).requirements
            end
          end

          class RequirementsBuilder
            def initialize(requirement_schema:, fallback_sheets:, state:)
              @requirement_schema = requirement_schema
              @fallback_sheets = fallback_sheets
              @state = state
            end

            attr_reader :requirement_schema, :fallback_sheets, :state

            delegate :xml, :xlsx, to: :state

            def requirements
              @requirements ||= if xml?
                xml_requirements
              else
                xlsx_requirements
              end
            end

            def xlsx_requirements
              sheet_names.map do |sheet_name|
                ExcelDataServices::V4::Files::Requirement.new(content: content, xlsx: xlsx, sheet_name: sheet_name, rows: rows, columns: columns)
              end
            end

            def xml_requirements
              [XmlRequirement.new(content: xml, path: path)]
            end

            def type
              requirement_schema[:type]
            end

            def rows
              requirement_schema[:rows]
            end

            def columns
              requirement_schema[:columns]
            end

            def content
              requirement_schema[:content]
            end

            def path
              requirement_schema[:path]
            end

            def sheet_names
              if requirement_schema[:sheet_names].present?
                requirement_schema[:sheet_names] & fallback_sheets
              else
                fallback_sheets
              end
            end

            def xml?
              type == "xml"
            end
          end
        end
      end
    end
  end
end
