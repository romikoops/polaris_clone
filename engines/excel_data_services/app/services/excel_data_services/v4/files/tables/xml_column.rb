# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Tables
        class XmlColumn
          attr_reader :xml_data, :header, :key, :options, :identifier

          def initialize(xml_data:, header:, key:, identifier:, options: Options.new)
            @xml_data = xml_data
            @options = options
            @key = key
            @header = header
            @identifier = identifier
          end

          def frame
            @frame ||= Rover::DataFrame.new(cell_frame_data)
          end

          def sheet_name
            identifier
          end

          def valid?
            errors.empty?
          end

          def errors
            @errors ||= [
              options.errors,
              cells.map(&:error),
              uniqueness_constraint_error,
              required_data_missing_error
            ].flatten.compact
          end

          alias present_on_sheet? valid?

          private

          def data_for_cells
            @data_for_cells ||= data_from_xml.presence || ([fallback] * xml_data.count_for(identifier: identifier))
          end

          def data_from_xml
            @data_from_xml ||= xml_data.data_for(key: key, identifier: identifier)
          end

          delegate :fallback, :fallback_configured?, :dynamic, :alternative_keys, :required, :sanitizer, :validator, :type, to: :options

          def cell_frame_data
            @cell_frame_data ||= cells.map.with_index do |cell, index|
              {
                "value" => cell.value,
                "row" => index + 1
              }.merge(frame_data_row_base)
            end
          end

          def frame_data_row_base
            @frame_data_row_base ||= {
              "header" => header,
              "sheet_name" => sheet_name,
              "target_frame" => "default",
              "column" => key,
              "organization_id" => Organizations.current_id
            }
          end

          def cells
            @cells ||= data_for_cells.map.with_index do |input, index|
              ExcelDataServices::V4::Files::Tables::CellParser.new(
                container: self,
                column: key,
                row: index + 1,
                input: input
              )
            end
          end

          def uniqueness_constraint_error
            return unless unique?

            duplicate_groupings = cells.reject(&:blank?)
              .group_by { |cell| cell.value && cell.sheet_name }
              .values
              .reject { |cell_grouping| cell_grouping.length == 1 }
            return if duplicate_groupings.empty?

            duplicate_groupings.map do |duplicates|
              error_locations = duplicates.map(&:location).join(" & ")
              ExcelDataServices::V4::Files::Error.new(
                type: :type_error,
                row_nr: duplicates.first.row,
                col_nr: duplicates.first.column,
                sheet_name: duplicates.first.sheet_name,
                reason: "Duplicates exist at #{error_locations}. Please remove all duplicate data and try again.",
                exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks::DuplicateDataFound
              )
            end
          end

          def required_data_missing_error
            blank_cells = cells.select(&:blank?)
            return if required.blank? || (required.present? && blank_cells.empty?)

            blank_cells.map do |blank_cell|
              ExcelDataServices::V4::Files::Error.new(
                type: :type_error,
                row_nr: blank_cell.row,
                col_nr: blank_cell.column,
                sheet_name: blank_cell.sheet_name,
                reason: "Required data is missing at: #{blank_cell.location}. Please fill in the missing data and try again.",
                exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks::RequiredDataMissing
              )
            end
          end

          def unique?
            options.unique
          end
        end
      end
    end
  end
end
