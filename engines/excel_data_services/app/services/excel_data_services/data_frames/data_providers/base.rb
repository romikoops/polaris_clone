# frozen_string_literal: true

# DataProviders are the classes that handle extraction of data from the Excel sheets.
# Given a Schemas::Sheet class it will pull the info out of the XLSX and create DataFrame
# ready to be used in creating the Table

module ExcelDataServices
  module DataFrames
    module DataProviders
      class Base < ExcelDataServices::DataFrames::Base
        UNDEFINED_VALUES = %w[n/a - N/A].freeze

        def perform
          @state.frame = frame
          state
        end

        def frame
          @frame ||= Rover::DataFrame.new(data, types: self.class.column_types)
        end

        private

        def sheet
          state.schema.sheet
        end

        def sheet_name
          state.schema.sheet_name
        end

        def headers
          @headers ||= extract_from_schema(section: "headers")
        end

        def header_for_cell(cell:)
          headers.find { |header| header.col == cell.col }
        end

        def data
          structure = basic_structure
          cell_data.sort_by(&:row).each do |cell|
            header = header_for_cell(cell: cell)
            structure[header.value.downcase] << cell.value
          end

          structure
        end

        def basic_structure
          headers.reject(&:blank?).each_with_object({}) { |header, result|
            header_key = header.value.downcase
            result[header_key] = []
          }.merge("sheet_name" => sheet_name)
        end

        def extract_from_schema(section:)
          state.schema.content_positions(section: section).to_a.map { |position|
            value = sheet.cell(position[:row], position[:col])
            next unless value_defined?(value: value)

            ExcelDataServices::DataFrames::DataProviders::Cell.new(
              value: value,
              row: position[:row],
              col: position[:col],
              label: label,
              sheet_name: sheet_name
            )
          }.compact
        end

        def value_defined?(value:)
          UNDEFINED_VALUES.exclude?(value)
        end

        def column_types
          {}
        end

        def rows_frame_with_query_method
          rows_frame["identifier"] = identifier
          rows_frame["sheet_name"] = sheet_name
          rows_frame.inner_join(query_methods, on: {"identifier" => "identifier"})
        end

        def query_methods
          Rover::DataFrame.new([
            {"query_method" => "location", "identifier" => "city"},
            {"query_method" => "location", "identifier" => "postal_code"},
            {"query_method" => "location", "identifier" => "locode"},
            {"query_method" => "zipcode", "identifier" => "zipcode"},
            {"query_method" => "distance", "identifier" => "distance"}
          ])
        end

        def identifier
          extract_from_schema(section: "identifier").first.value.downcase
        end
      end
    end
  end
end
