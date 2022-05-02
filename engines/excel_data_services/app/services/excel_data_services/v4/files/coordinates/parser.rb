# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Coordinates
        class Parser
          attr_reader :sheet, :input_rows, :input_columns

          def initialize(sheet:, input_rows:, input_columns:)
            @sheet = sheet
            @input_rows = input_rows
            @input_columns = input_columns
          end

          def rows
            @rows ||= Axis.new(sheet: sheet, coordinates: input_rows, axis: :row, counterparts: input_columns).perform
          end

          def columns
            @columns ||= Axis.new(sheet: sheet, coordinates: input_columns, axis: :column, counterparts: input_rows).perform
          end

          class Axis
            ALPHA_INDEX = ExcelDataServices::V4::Files::Tables::Column::ALPHA_INDEX
            NA_COLUMN = "N/A"
            attr_reader :sheet, :coordinates, :axis, :counterparts

            def initialize(sheet:, coordinates:, counterparts:, axis:)
              @sheet = sheet
              @coordinates = coordinates
              @counterparts = counterparts
              @axis = axis
              raise ArgumentError unless coordinates.nil? || coordinates.is_a?(String)
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
              @completed_coordinates ||= if coordinates.include?("?")
                coordinates.gsub("?", last_counterpart_value)
              else
                coordinates
              end
            end

            def last_counterpart_value
              @last_counterpart_value ||= if row?
                last_counterpart_values.to_s
              else
                ALPHA_INDEX.key(last_counterpart_values).to_s
              end
            end

            def last_counterpart_values
              @last_counterpart_values ||= valid_counterpart_values.map do |counter|
                if row?
                  last_present_index(collection: sheet.column(counter))
                else
                  last_present_index(collection: sheet.row(counter.to_i))
                end
              end.max
            end

            def valid_counterpart_values
              @valid_counterpart_values ||= counterparts.split(":").reject { |char| char == "?" }
            end

            def row?
              axis == :row
            end

            def last_present_index(collection:)
              collection.filter_map.with_index { |val, index| index + 1 if val.present? }.max
            end
          end
        end
      end
    end
  end
end
