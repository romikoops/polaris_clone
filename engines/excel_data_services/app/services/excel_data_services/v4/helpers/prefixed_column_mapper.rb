# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Helpers
      class PrefixedColumnMapper
        def initialize(mapped_object:, header:)
          @mapped_object = mapped_object
          @header = header
        end

        def perform
          destinations.zip(origins).each do |destination, origin|
            mapped_object[destination] = mapped_object.delete(origin)
          end
          mapped_object.delete("header")
          mapped_object
        end

        def coordinate_keys
          @coordinate_keys ||= %w[row column] & mapped_object.keys
        end

        def origins
          coordinate_keys + %w[value]
        end

        def destinations
          coordinate_keys.map { |key| [header, key].join("_") } + [header]
        end

        private

        attr_reader :mapped_object, :header
      end
    end
  end
end
