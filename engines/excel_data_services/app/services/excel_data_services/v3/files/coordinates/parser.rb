# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Coordinates
        class Parser
          ALPHA_INDEX = ExcelDataServices::V3::Files::Tables::Column::ALPHA_INDEX
          NA_COLUMN = "N/A"
          attr_reader :sheet, :coordinates, :axis

          def initialize(sheet:, coordinates:, axis:)
            @sheet = sheet
            @coordinates = coordinates
            @axis = axis
          end

          def perform
            return [NA_COLUMN] if coordinates.blank?
            return sequence if axis == :row

            sequence.map { |seq| ALPHA_INDEX.key(seq) }
          end

          private

          def sequence
            @sequence ||= lower_limit.upto(upper_limit).to_a
          end

          def lower_limit
            @lower_limit ||= numerical_coordinate(coordinate: coordinate_array.first)
          end

          def upper_limit
            @upper_limit ||= numerical_coordinate(coordinate: coordinate_array.last)
          end

          def coordinate_array
            @coordinate_array ||= completed_coordinates.split(":")
          end

          def numerical_coordinate(coordinate:)
            return coordinate if coordinate.is_a?(Integer)
            return coordinate.to_i if coordinate.match?(/\A[0-9]{1,}\z/)

            ALPHA_INDEX[coordinate]
          end

          def completed_coordinates
            @completed_coordinates ||= coordinates.gsub("?", axis == :row ? sheet.last_row.to_s : sheet.last_column_as_letter)
          end
        end
      end
    end
  end
end
