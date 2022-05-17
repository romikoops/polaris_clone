# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Schema
          SCHEMA_PATH = [Rails.root, "/engines/excel_data_services/app/services/excel_data_services/v4/files/sections"].join
          InvalidSection = Class.new(ArgumentError)

          attr_reader :path, :section, :keys

          def initialize(section:, keys:)
            @section = section
            @keys = keys

            raise InvalidSection unless section_path_is_valid?
          end

          def perform
            return data unless block_given?

            yield(data)
          end

          private

          def data
            keys.zip([[]] * keys.length).to_h.merge(schema.slice(*keys).compact)
          end

          def schema
            @schema ||= YAML.load_file(section_path).deep_symbolize_keys!
          end

          def section_path
            "#{SCHEMA_PATH}/#{section.underscore}.yml"
          end

          def section_path_is_valid?
            File.exist?(section_path)
          end
        end
      end
    end
  end
end
