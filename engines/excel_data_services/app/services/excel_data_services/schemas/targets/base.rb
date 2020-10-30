# frozen_string_literal: true

module ExcelDataServices
  module Schemas
    module Targets
      class Base
        attr_reader :source, :section, :axis

        delegate :schema, :sheet, to: :source

        def self.targets(source:, section:, axis:)
          klass = ExcelDataServices::Schemas::Targets::Base.get(coordinates: source.schema.dig(section, axis))
          klass.new(source: source, section: section, axis: axis).perform
        end

        def self.get(coordinates:)
          case coordinates
          when /\?/
            ExcelDataServices::Schemas::Targets::Dynamic
          when /last_/, /first_/
            ExcelDataServices::Schemas::Targets::Relative
          when /\||,/
            ExcelDataServices::Schemas::Targets::List
          else
            ExcelDataServices::Schemas::Targets::Range
          end
        end

        def initialize(source:, section:, axis:)
          @source = source
          @section = section
          @axis = axis
        end

        def perform
          wrap_array(array: raw_data)
        end

        def wrap_array(array:)
          array.map { |item| [item] }
        end

        def coordinate_target
          @coordinate_target ||= schema.dig(section, axis)
        end
      end
    end
  end
end
