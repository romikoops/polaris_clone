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

        def col_from_header(header:)
          headers.find { |header_cell| header_cell.value.downcase == header }&.col
        end

        def data
          columns = cell_data.group_by(&:col)
          basic_structure.keys.each_with_object(Hash.new { |h, k| h[k] = [] }) { |header, structure|
            col = col_from_header(header: header)
            if columns[col].blank?
              structure[header] << parse_cell_value(header: header)
            else
              columns[col].sort(&:row).each do |cell|
                structure[header] << parse_cell_value(cell: cell, header: header)
              end
            end
            structure
          }.merge("sheet_name" => [sheet_name])
        end

        def basic_structure
          self.class.column_types.keys.each_with_object({}) { |header, result|
            result[header] = []
          }
        end

        def extract_from_schema(section:)
          state.schema.content_positions(section: section).to_a.map { |position|
            value = cell_value(position: position)
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

        def cell_value(position:)
          if sheet.celltype(position[:row], position[:col]) == :date
            sheet.cell(position[:row], position[:col])
          else
            sheet.excelx_value(position[:row], position[:col])
          end
        end

        def parse_cell_value(header:, cell: nil)
          parser = ExcelDataServices::DataFrames::DataProviders::Parser.new(
            cell: cell,
            header: header,
            section: self.class.name.demodulize
          )
          state.errors << parser.error if parser.error.present?
          parser.value
        end

        def parse_cell_data(header:, cell:)
          cell.data.merge(header => parse_cell_value(header: header, cell: cell))
        end

        def value_defined?(value:)
          UNDEFINED_VALUES.exclude?(value)
        end

        def column_types
          {}
        end

        def query_method
          {
            "city" => "location",
            "postal_code" => "location",
            "locode" => "location",
            "zipcode" => "zipcode",
            "distance" => "distance"
          }[identifier]
        end

        def identifier
          extract_from_schema(section: "identifier").first.value.downcase
        end
      end
    end
  end
end
