# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Parsers
        class Schema
          SCHEMA_PATH = [Rails.root, "/engines/excel_data_services/app/services/excel_data_services/v3/files"].join
          VALID_PATHS = %w[section_data file_data].freeze
          InvalidPath = Class.new(ArgumentError)
          InvalidPattern = Class.new(ArgumentError)
          InvalidSection = Class.new(ArgumentError)

          attr_reader :path, :section, :pattern

          def initialize(path:, section:, pattern:)
            @path = path
            @section = section
            @pattern = pattern

            raise InvalidPath unless VALID_PATHS.include?(path)
            raise InvalidPattern unless pattern.is_a?(Regexp)
            raise InvalidSection unless section_path_is_valid?
          end

          def perform
            return schema_lines unless block_given?

            yield(schema_lines)
          end

          def dependencies
            raw_lines.grep(/^(prerequisite)/).map { |raw_line| raw_line.gsub("prerequisite", "").delete('"').strip }
          end

          private

          def schema_lines
            raw_lines.grep(pattern).join
          end

          def raw_lines
            @raw_lines ||= File.read(section_path).lines
          end

          def section_path
            "#{SCHEMA_PATH}/#{path}/#{section.underscore}"
          end

          def section_path_is_valid?
            File.exist?(section_path)
          end
        end
      end
    end
  end
end
