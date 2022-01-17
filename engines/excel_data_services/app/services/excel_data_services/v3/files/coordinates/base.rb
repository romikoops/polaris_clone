# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Coordinates
        # The Coordinate classes take the row and column data defined in the config file and extract all content from the xlsx
        class Base
          attr_reader :sheet, :range, :coordinates, :counterpart, :axis

          def self.extract(sheet:, coordinates:, counterpart:, axis:)
            klass = CoordinateSwitch.new(coordinates: coordinates).perform
            klass.new(sheet: sheet, coordinates: coordinates, counterpart: counterpart, axis: axis).perform
          end

          def initialize(sheet:, coordinates:, counterpart:, axis:)
            @sheet = sheet
            @coordinates = coordinates
            @counterpart = counterpart
            @axis = axis
          end

          def perform
            return [lower_limit, upper_limit] if lower_limit == upper_limit

            lower_limit.upto(upper_limit).to_a
          end

          def limits
            []
          end

          def lower_limit
            @lower_limit ||= NumericalInput.new(input: limits.first).value
          end

          def upper_limit
            @upper_limit ||= NumericalInput.new(input: limits.last).value
          end

          def counterpart_axis
            @counterpart_axis ||= axis == "rows" ? "cols" : "rows"
          end

          # Private class for determining the type of Coordinate cllass to use
          class CoordinateSwitch
            def initialize(coordinates:)
              @coordinates = coordinates
            end

            def perform
              case coordinates
              when /\?/
                ExcelDataServices::V3::Files::Coordinates::Dynamic
              when /last_/, /first_/
                ExcelDataServices::V3::Files::Coordinates::Relative
              when /\||,/
                ExcelDataServices::V3::Files::Coordinates::List
              else
                ExcelDataServices::V3::Files::Coordinates::Range
              end
            end

            private

            attr_reader :coordinates
          end

          # Private class for ensuring numericality of the value
          class NumericalInput
            ALPHA_INDEX = ("A".."ZZ").each.with_index(1).to_h.freeze

            def initialize(input:)
              @input = input
            end

            def value
              return 1 if input.blank?
              return input if input.is_a?(Integer)
              return ALPHA_INDEX[input] if input.match?(/[a-zA-Z]{1,}/)

              input.to_i
            end

            private

            attr_reader :input
          end
        end
      end
    end
  end
end
