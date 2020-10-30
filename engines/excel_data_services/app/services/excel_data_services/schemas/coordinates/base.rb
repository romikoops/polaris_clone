# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Coordinates
      class Base
        attr_reader :source, :section, :axis

        delegate :schema, :sheet, to: :source

        ALPHA_INDEX = ("A".."ZZ").each.with_index(1).to_h.freeze

        def self.get(coordinates:)
          case coordinates
          when /\?/
            ExcelDataServices::Schemas::Coordinates::Dynamic
          when /last_/, /first_/
            ExcelDataServices::Schemas::Coordinates::Relative
          when /\||,/
            ExcelDataServices::Schemas::Coordinates::List
          else
            ExcelDataServices::Schemas::Coordinates::Range
          end
        end

        def self.extract(source:, section:, axis:)
          klass = ExcelDataServices::Schemas::Coordinates::Base.get(coordinates: source.schema.dig(section, axis))
          klass.new(source: source, section: section, axis: axis).perform
        end

        def initialize(source:, section:, axis:)
          @source = source
          @section = section
          @axis = axis
        end

        def perform
          return [lower_limit, upper_limit] if lower_limit == upper_limit

          lower_limit.upto(upper_limit).to_a
        end

        def coordinates
          @coordinates ||= schema.dig(section, axis)
        end

        def counterpart_axis
          @counterpart_axis ||= axis == "rows" ? "cols" : "rows"
        end

        def limits
          []
        end

        def lower_limit
          @lower_limit ||= numerical_value(input: limits.first) || 1
        end

        def upper_limit
          @upper_limit ||= numerical_value(input: limits.last) || 1
        end

        def numerical_value(input:)
          return input if input.blank? || input.is_a?(Integer)
          return ALPHA_INDEX[input] if input.match?(/[a-zA-Z]{1,}/)

          input.to_i
        end
      end
    end
  end
end
